# Enable Compute API
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

# Enable container API for the GKE cluster
resource "google_project_service" "container" {
  service                    = "container.googleapis.com"
  disable_dependent_services = true
}

#VPC
resource "google_compute_network" "vpc" {
  name                            = "my-vpc"
  routing_mode                    = "GLOBAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

#subnets
resource "google_compute_subnetwork" "workload-sb" {
  name                     = "workload"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region[0]
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

}

resource "google_compute_subnetwork" "management-sb" {
  name                     = "management"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = var.region[1]
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

#Routers
resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region[1]
  network = google_compute_network.vpc.id
}

#NAT 
resource "google_compute_router_nat" "nat" {
  name   = "nat"
  router = google_compute_router.router.name
  region = var.region[1]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "AUTO_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.management-sb.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

#Enable IAP
resource "google_project_service" "iap" {
  service = "iap.googleapis.com"
}

#Firewall
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["management-vm"]
  source_ranges = ["35.235.240.0/20"]   # modify it later
}
