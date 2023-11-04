resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region[1]
  repository_id = "project-repo"
  description   = "docker repository"
  format        = "DOCKER"
}