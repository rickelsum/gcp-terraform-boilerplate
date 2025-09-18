locals {
  env = "prod"
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

module "gke_cluster" {
  source = "../../modules/gke_cluster"

  project_id   = var.project_id
  region       = var.region
  cluster_name = "gke-cluster-staging"
  ar_repo_name = var.ar_repo_name
}