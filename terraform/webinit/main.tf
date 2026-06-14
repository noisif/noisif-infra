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
    ".css"   = "text/css"
    ".svg"   = "image/svg+xml"
    ".ico"   = "image/x-icon"
    ".webp"  = "image/webp"
    ".woff2" = "font/woff2"
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
  cache_control = "public, max-age=0, s-maxage=60"
}

resource "cloudflare_record" "website_dns" {
  zone_id = var.cloudflare_zone_id
  name    = "noisif.xyz"
  content = "c.storage.googleapis.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_redirect_rule" "www_to_root" {
  zone_id = var.cloudflare_zone_id
  name    = "Redirect WWW to root"
  status  = "active"

  trigger_expression = "http.host eq \"www.noisif.xyz\""

  action {
    type = "redirect"
    redirect {
      target_url {
        expression = "concat(\"https://noisif.xyz\", http.request.uri.path)"
      }
      status_code           = 301
      preserve_query_string = true
    }
  }
}
