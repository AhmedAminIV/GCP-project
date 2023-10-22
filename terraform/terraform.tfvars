gcp_svc_key     = "../gcp-amin-199315a674db.json"
startup_script  = "./startup_script.sh"
project_id      = "gcp-amin"
region          = ["us-east1", "us-central1"]
zone            = "us-east1-b"
workerload_cidr   = "10.0.1.0/24"
management_cidr = "10.0.2.0/24"
control_plane_cidr = "172.16.0.0/28"
vm_roles = [
  "roles/source.reader",
  "roles/artifactregistry.writer",
  "roles/container.clusterAdmin",
]
network_tags         = ["management-vm"]
machine_type         = "n2-standard-2"
image                = "debian-cloud/debian-11"
workers_machine_type = "e2-small"
workers_image        = "cos_containerd"
workers_disk         = 30
