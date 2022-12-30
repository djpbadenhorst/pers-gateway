module "vpc" {
  source  = "terraform-google-modules/network/google"
  project_id   = var.project_id
  network_name = "vpc"
  
  subnets = [{
    subnet_name           = "subnet-primary"
    subnet_ip             = "10.10.0.0/16"
    subnet_region         = var.region
    subnet_private_access = true
  },{
    subnet_name           = "subnet-access-connector"
    subnet_ip             = "10.8.0.0/28"
    subnet_region         = var.region
  }]
}

module "access_connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  project_id = var.project_id
  
  vpc_connectors = [{
    name           = "access-connector"
    subnet_name    = "subnet-access-connector"
    region         = var.region
    max_throughput = 300
  }]
}

resource "google_compute_router" "router" {
  project = var.project_id
  region  = var.region
  name    = "router"
  network = module.vpc.network_id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  region                             = var.region
  name                               = "nat"
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}

resource "google_compute_firewall" "allow_ssh" {
  name      = "allow-ssh"
  project   = var.project_id
  network   = module.vpc.network_name
  direction = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}
