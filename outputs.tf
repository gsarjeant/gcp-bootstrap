output "terraform_service_account_email" {
  value       = google_service_account.terraform_service_account.email
  description = "The emil address of the GCP terraform service account"
}

output "terraform_state_storage_bucket_name" {
  value       = google_storage_bucket.terraform_state_storage_bucket.name
  description = "The ID of the cloud storage bucket that holds remote state."
}

output "terraform_state_storage_bucket_url" {
  value       = google_storage_bucket.terraform_state_storage_bucket.url
  description = "The ID of the cloud storage bucket that holds remote state."
}
