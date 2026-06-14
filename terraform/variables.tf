variable "gcp_project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
}
