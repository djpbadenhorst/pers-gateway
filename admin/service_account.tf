resource "google_service_account" "gateway" {
  project      = var.project_id
  account_id   = "gateway-sa"
  display_name = "gateway-sa"
}

resource "google_service_account_key" "gateway" {
  service_account_id = "${google_service_account.gateway.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
}

resource "google_service_account" "auth" {
  project      = var.project_id
  account_id   = "auth-sa"
  display_name = "auth-sa"
}

resource "google_service_account_key" "auth" {
  service_account_id = "${google_service_account.auth.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
}

module "project_iam_bindings" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "additive"

  bindings = {
    "roles/viewer" = [
      "serviceAccount:${google_service_account.gateway.email}",
    ]
    "roles/logging.logWriter" = [
      "serviceAccount:${google_service_account.gateway.email}",
    ]
    "roles/monitoring.metricWriter" = [
      "serviceAccount:${google_service_account.gateway.email}",
    ]
    "roles/compute.admin" = [
      "serviceAccount:${google_service_account.auth.email}",
    ]
  }
}
