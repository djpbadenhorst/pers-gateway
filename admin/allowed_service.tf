resource "google_project_service" "allow_compute" {
  project = var.project_id
  service = "compute.googleapis.com"
  
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "allow_containerregistry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
  
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "allow_run" {
  project = var.project_id
  service = "run.googleapis.com"
  
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "allow_vpcaccess" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
  
  disable_on_destroy         = true
  disable_dependent_services = true
}

resource "google_project_service" "allow_logging" {
  project = var.project_id
  service = "logging.googleapis.com"
  
  disable_on_destroy         = true
  disable_dependent_services = true
}
