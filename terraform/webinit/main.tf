resource "google_storage_bucket" "website" {
  name          = "noisif.xyz"
  location      = var.region
  force_destroy = true

  website {
    main_page_suffix = "index.html"
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

locals {
  website_source_dir = "${path.module}/webcontent"
  website_files = fileset(local.website_source_dir, "**/*")

  mime_types = {
    ".html"  = "text/html"
    ".svg"   = "image/svg+xml"
    ".ico"   = "image/x-icon"
    ".webp"  = "image/webp"
  }
}

resource "google_storage_bucket_object" "website_files" {
  for_each = local.website_files

  name   = each.value
  source = "${local.website_source_dir}/${each.value}"
  bucket = google_storage_bucket.website.name

  content_type = lookup(
    local.mime_types,
    regex("\\.[^.]+$", each.value),
    "application/octet-stream"
  )
}

resource "cloudflare_record" "website_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "noisif.xyz"
  content = "c.storage.googleapis.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "www_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "www"
  content = "noisif.xyz"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_zone_setting" "ssl_mode" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "ssl"
  value      = "flexible"
}

resource "cloudflare_zone_setting" "https_redirect" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_zone_setting" "tls_version" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "min_tls_version"
  value      = "1.2"
}

resource "cloudflare_zone_setting" "minify_code" {
  zone_id    = var.cloudflare_zone_id
  setting_id = "minify"
  value      = jsonencode({
    css  = "on"
    html = "on"
    js   = "on"
  })
}
