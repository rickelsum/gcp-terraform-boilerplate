variable "project_id" {
  description = "The GCP project ID where the certificate will be created."
  type        = string
}

variable "certificate_name" {
  description = "A unique name for the SSL certificate resource."
  type        = string
}

variable "domain_name" {
  description = "The domain name the certificate will be issued for (e.g., app.your-domain.com)."
  type        = string
}