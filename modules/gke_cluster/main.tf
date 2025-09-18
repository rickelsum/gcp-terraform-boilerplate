resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  project                  = var.project_id
  name                     = var.subnetwork_name
  ip_cidr_range            = "10.10.0.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
}

resource "google_container_cluster" "primary" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.vpc_subnetwork.id

  # Using a cost-effective Autopilot cluster
  enable_autopilot = true

  # Remove the default node pool created with standard clusters
  remove_default_node_pool = true
  initial_node_count       = 1
}

# This resource was created by the setup.sh script, but we import it
# into Terraform's state so Terraform is aware of it.
resource "google_artifact_registry_repository" "docker_repo" {
  project       = var.project_id
  location      = var.region
  repository_id = var.ar_repo_name
  description   = "Docker repository for Nuxt application"
  format        = "DOCKER"
}