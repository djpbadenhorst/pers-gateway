output "gateway_sa_email" {
  value = google_service_account.gateway.email
}

output "auth_sa_email" {
  value = google_service_account.auth.email
}
