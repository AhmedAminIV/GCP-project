# Enable IAM API
resource "google_project_service" "project" {
  service                    = "iam.googleapis.com"
  disable_dependent_services = true
}

# service accounts
resource "google_service_account" "vm-sa" {
  account_id = "managementvm"
  display_name = "Management-VM-SA"
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam
resource "google_project_iam_member" "vm-sa-roles" {
  project = var.project_id
  count   = length(var.vm_roles)
  role    = var.vm_roles[count.index]
  member  = "serviceAccount:${google_service_account.vm-sa.email}"
}

resource "google_service_account" "pool-sa" {
  account_id = "pool-sa"
  display_name = "cluster's node pool service account"
}

