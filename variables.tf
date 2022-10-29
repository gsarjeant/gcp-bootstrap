variable "project" {
  type        = string
  description = "The google cloud project ID being managed"
}

variable "region" {
  type        = string
  default     = ""
  description = "Region in which to create resources."
}

variable "dual_region" {
  type        = string
  default     = ""
  description = "Region in which to create higher-availability resources."
}

variable "labels" {
  type        = map(string)
  description = "A map of labels to be applied to all resources managed by this module"
}

variable "enabled_apis" {
  type        = list(string)
  description = "The APIs that should be enabled to provide access to project features."
}

variable "kms_crypto_key_rotation_period" {
  type        = string
  description = "The amount of time in seconds after which to rotate the state bucket's KMS crypto key"
}

# Note: Look into driving this off of IAM accounts directly.
variable "admin_email_addresses" {
  type        = list(string)
  description = "email addresses of members who can administer the project via terraform"
}

variable "admin_iam_roles" {
  type        = list(string)
  description = "roles granted to the terraform service account and admin IAM accounts"
}

variable "max_saved_states" {
  type        = number
  default     = 50
  description = "The maximum number of non-live versions of the state to keep in the cloud storage bucket. Once reached, older versions will be deleted."
}

variable "tfstate_bucket_name" {
  type        = string
  description = "The name of the GCP storage bucket that will store terraform remote state."
}
