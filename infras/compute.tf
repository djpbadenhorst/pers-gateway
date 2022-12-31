data "template_file" "vm_startup" {
  template = "${file("./scripts/vm_startup.sh")}"
  vars = {
    tailscale_authkey = var.tailscale_authkey
    ssh_password = var.ssh_password
    gateway_ip = var.gateway_ip
  }
}

data "google_compute_subnetwork" "primary" {
  project = var.project_id
  region  = var.region
  name    = "subnet-primary"

  depends_on = [module.vpc]
}

resource "google_compute_address" "gateway" {
  project = var.project_id
  region  = var.region
  name    = "gateway"

  subnetwork   = data.google_compute_subnetwork.primary.self_link
  address      = var.gateway_ip
  address_type = "INTERNAL"
}

resource "google_compute_instance" "gateway" {
  project = var.project_id
  name    = "gateway"
  
  machine_type = "e2-micro"
  zone         = "${var.region}-b"
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  service_account {
    email  = var.gateway_sa_email
    scopes = [ "cloud-platform" ]
  }

  network_interface {
    network    = module.vpc.network_self_link
    subnetwork = data.google_compute_subnetwork.primary.self_link
    network_ip = google_compute_address.gateway.address
  }

  tags = [ "http-server", "allow-ssh" ]
  
  metadata_startup_script = data.template_file.vm_startup.rendered
}
