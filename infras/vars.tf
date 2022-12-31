variable "project_id" {
  default = "djpb-1313"
}

variable "region" {
  default = "europe-west1"
}

variable "domain" {
  default = "djpb.info"
}

variable "auth_sa_email" {
  default = "auth-sa@djpb-1313.iam.gserviceaccount.com"
}

variable "gateway_sa_email" {
  default = "gateway-sa@djpb-1313.iam.gserviceaccount.com"
}

variable "gateway_ip" {
  default = "10.10.10.10"
}

# Environment Variables
variable "tailscale_authkey" {}
variable "flask_secret" {}
variable "ssh_password" {}
