# private VM
resource "google_compute_instance" "management-vm" {
  name         = "management-vm"
  zone         = "us-central1-a"
  machine_type = var.machine_type
  tags         = var.network_tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.management-sb.name
  }
  
  depends_on = [
    google_service_account_key.vm-sa-key,
    google_artifact_registry_repository.my-repo,
    google_container_cluster.my-cluster,
  ]

  metadata = {
    "service-account-key" = google_service_account_key.vm-sa-key.private_key
  }

  metadata_startup_script = file(var.startup_script)

  service_account {
    email  = google_service_account.vm-sa.email
    scopes = var.scopes
  }
}

# Cluster
resource "google_container_cluster" "my-cluster" {
  name                     = "cluster"
  location                 = "us-east1-b"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc.self_link
  subnetwork               = google_compute_subnetwork.workload-sb.self_link
  networking_mode          = "VPC_NATIVE"
  deletion_protection      = false


  node_locations = [
    "us-east1-c",
    "us-east1-d"
  ]

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = var.management_cidr
    }
  }

  node_config {
    disk_size_gb = var.workers_disk
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.control_plane_cidr
  }

  depends_on = [
    google_project_service.container
  ]

}

# Pool
resource "google_container_node_pool" "workers-pool" {
  name       = "workers-pool"
  cluster    = google_container_cluster.my-cluster.id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible     = false
    machine_type    = var.workers_machine_type
    image_type      = var.workers_image
    disk_size_gb    = var.workers_disk
    service_account = google_service_account.pool-sa.email
  }
}
