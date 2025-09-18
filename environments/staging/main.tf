locals {
  env = "staging"
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for resources."
  type        = string
}

variable "ar_repo_name" {
  description = "The name for the Artifact Registry repository."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the SSL certificate."
  type        = string
}

module "gke_cluster" {
  source = "../../modules/gke_cluster"

  project_id   = var.project_id
  region       = var.region
  cluster_name = "gke-cluster-staging"
  ar_repo_name = var.ar_repo_name
}

# Provision the Google-managed SSL certificate for our domain
module "gke_certificate" {
  source = "../../modules/gke-certificate" # <-- Note the new module source path

  project_id       = var.project_id
  certificate_name = "gke-cert-staging" # A unique name for the cert
  domain_name      = var.domain_name
}