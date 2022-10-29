locals {
  admin_accounts = [for email in var.admin_email_addresses : "user:${email}"]
}

# enable required APIs
resource "google_project_service" "enabled-api" {
  for_each = toset(var.enabled_apis)
  project  = var.project
  service  = each.value
}

# Create a keyring to hold our managed crypto key for the state file
resource "google_kms_key_ring" "tfstate-key-ring" {
  name     = "kms-key-ring-tfstate-${var.project}"
  project  = var.project
  location = var.dual_region
  depends_on = [
    google_project_service.enabled-api
  ]
}

# Create a managed crypto key in the keyring
resource "google_kms_crypto_key" "tfstate-key" {
  name            = "kms-crypto-key-${var.project}"
  key_ring        = google_kms_key_ring.tfstate-key-ring.id
  rotation_period = var.kms_crypto_key_rotation_period
  purpose         = "ENCRYPT_DECRYPT"

  lifecycle {
    prevent_destroy = false
  }
  labels = merge(
    var.labels,
    {
      "name" = "kms-crypto-key-${var.project}"
    },
  )
}

# Grant the google cloud storage service account access to the KMS key for the storage bucket
data "google_storage_project_service_account" "gcs_account" {
}

resource "google_kms_crypto_key_iam_binding" "tfstate-key-binding" {
  crypto_key_id = google_kms_crypto_key.tfstate-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_service_account" "terraform_service_account" {
  project      = var.project
  account_id   = "${var.project}-terraform"
  display_name = "Terraform Service Account"
  description  = "Managed by terraform"
}

resource "google_storage_bucket" "terraform_state_storage_bucket" {
  name                        = "${var.project}_tfstate_storage_bucket"
  project                     = var.project
  location                    = var.dual_region
  uniform_bucket_level_access = true
  labels = merge(
    var.labels,
    {
      "name" = "${var.project}_tfstate_storage_bucket"
    },
  )

  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.tfstate-key.id
  }
  lifecycle {
    prevent_destroy = true
  }
  lifecycle_rule {
    condition {
      num_newer_versions = var.max_saved_states
      with_state         = "ANY"
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_project_iam_binding" "admin_iam_roles" {
  project  = var.project
  for_each = toset(var.admin_iam_roles)
  role     = each.key

  members = concat(
    ["serviceAccount:${google_service_account.terraform_service_account.email}"],
    local.admin_accounts
  )
}

resource "google_service_account_iam_binding" "token-creator-iam" {
  service_account_id = google_service_account.terraform_service_account.id
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = concat(local.admin_accounts)
}
