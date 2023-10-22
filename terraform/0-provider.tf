# GCP provider

provider "google" {
  credentials = file(var.gcp_svc_key)
  project     = var.project_id
  region      = var.region[0]
  zone        = var.zone
}
