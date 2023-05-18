terraform {
  required_providers {
    google = {
      version = ">= 4.34.0"
    }
  }
  required_version = ">= 1.4.6"
}

locals {
  source_dir      = "${path.module}/../poc_func"
  zip_output_path = "${path.module}/../poc_func.zip"
  zip_name        = "poc_func.zip"
  bucket_name     = "signblob_poc"
  entry_point     = "proxy_downloader"
}

provider "google" {
  region  = var.gcp_region
}

data "google_project" "project" {

}

resource "random_id" "random_prefix" {
  byte_length = 4
}

data "archive_file" "source_code_zip" {
  type        = "zip"
  source_dir  = local.source_dir
  output_path = local.zip_output_path
}

resource "google_storage_bucket" "bucket" {
  name     = "${local.bucket_name}_${google_project.project.project_id}"
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = local.zip_name
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.source_code_zip.output_path
}

resource "google_cloudfunctions2_function" "function" {

  name        = "signblob_poc_${random_id.random_prefix.dec}"
  location    = var.gcp_region
  description = "PrivEsc PoC of a iam.signBlob permission via SSRF"

  build_config {
    runtime     = "python311"
    entry_point = local.entry_point # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.archive.name
      }
    }
  }

  service_config {
    max_instance_count    = 1
    available_memory      = "128Mi"
    timeout_seconds       = 60
    service_account_email = google_service_account.signurl_account.email
  }

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [
    google_project_service.gcp_services
  ]

  create_duration = "60s"
}

# IAM entry for all users to invoke the function
resource "google_cloud_run_v2_service_iam_member" "member" {
  project  = google_cloudfunctions2_function.function.project
  location = google_cloudfunctions2_function.function.location
  name     = google_cloudfunctions2_function.function.service_config[0].service
  role     = "roles/run.invoker"
  member   = "allUsers"
}