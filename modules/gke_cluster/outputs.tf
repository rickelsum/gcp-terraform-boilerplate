output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_location" {
  value = google_container_cluster.primary.location
}

output "project_id" {
  value = var.project_id
}

output "ar_repo_name" {
  value = google_artifact_registry_repository.docker_repo.name
}