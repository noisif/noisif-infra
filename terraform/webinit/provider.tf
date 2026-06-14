terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "noisif-tf-state"
    prefix = "terraform/state/webinit"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
