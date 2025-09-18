# This resource provisions a Google-managed SSL certificate that will
# automatically renew. Provisioning can take up to 15-20 minutes
# after the DNS A record points to the GKE Ingress IP.
resource "google_compute_managed_ssl_certificate" "gke_certificate" {
  project = var.project_id
  name    = var.certificate_name
  managed {
    domains = [var.domain_name]
  }
}