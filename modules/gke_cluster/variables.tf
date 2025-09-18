variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region for resources."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "gke-network"
}

variable "subnetwork_name" {
  description = "The name of the VPC subnetwork."
  type        = string
  default     = "gke-subnet"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "ar_repo_name" {
  description = "The name for the Artifact Registry repository."
  type        = string
}