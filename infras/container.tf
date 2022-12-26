resource "google_cloud_run_service" "auth" {
  project  = var.project_id
  location = var.region
  name     = "auth"
  
  template {
    spec {
      service_account_name = var.auth_sa_email
      containers {
	image = "gcr.io/djpb-1313/auth:latest"
	resources {
	  limits = {
	    cpu = "1000m"
	    memory = "1000Mi"
	  }
	}
	ports {
	  container_port = 80
	}
	env {
	  name = "GATEWAY_IP"
	  value = var.gateway_ip
	}
	env {
	  name = "FLASK_SECRET"
	  value = var.flask_secret
	}
      }
    }
    
    metadata {
      annotations = {
	"autoscaling.knative.dev/maxScale"        = "1"
	"run.googleapis.com/vpc-access-connector" = tolist(module.access_connector.connector_ids)[0]
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
      }
    }
  }
  autogenerate_revision_name = true
}

data "google_iam_policy" "auth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "auth" {
  project     = var.project_id
  location    = var.region
  service     = google_cloud_run_service.auth.name
  policy_data = data.google_iam_policy.auth.policy_data
}

resource "google_cloud_run_domain_mapping" "auth" {
  project  = var.project_id
  location = var.region
  name     = var.domain

  metadata { namespace = var.project_id }
  spec { route_name = google_cloud_run_service.auth.name }
}
