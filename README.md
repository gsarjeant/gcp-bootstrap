# GCP Bootstrap

This is a terraform module that sets up the core infrastructure that I tend to use on any Google Cloud Project. These are:

* Required APIs enabled (specified by variable)
* A service account to be used for terraform operations.
    * Admin accounts (specified by variable) are granted token creator permissions on this account for impersonation
* A cloud Storage Bucket to store remote state
* Dedicated KMS keyring and key to encrypt remote state
