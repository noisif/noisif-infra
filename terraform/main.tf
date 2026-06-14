module "static_website" {
  source = "./webinit"

  region = var.region
  cloudflare_zone_id = var.cloudflare_zone_id
}
