# This backend configuration is created by the setup.sh script
terraform {
  backend "gcs" {
    bucket = "your-tf-state-bucket-name" # <-- IMPORTANT: Replace this after running setup.sh
    prefix = "gke/staging"
  }
}