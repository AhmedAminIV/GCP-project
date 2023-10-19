# private VM
resource "google_compute_instance" "management-vm" {
  name         = "management-vm"
  zone         = "us-central1-a"
  machine_type = var.machine_type
  tags = var.network_tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.management-sb.name
  }

  metadata_startup_script = "echo hi > /test.txt"

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
        cidr_block = "10.0.2.0/24"
    }
  }
  
  node_config {
    disk_size_gb = var.workers_disk
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

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
    preemptible  = false
    machine_type = var.workers_machine_type
    image_type   = var.workers_image
    disk_size_gb = var.workers_disk
    service_account = google_service_account.pool-sa.email
  }
}