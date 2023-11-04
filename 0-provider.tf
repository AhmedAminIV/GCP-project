# GCP provider

provider "google" {
  project     = var.project_id
  region      = var.region[0]
  zone        = var.zone
}
