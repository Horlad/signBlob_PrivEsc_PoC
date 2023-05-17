locals {
  account_id = "signurl-account"
  role_id    = "signurl_role"
  apis_list = [
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "compute.googleapis.com"
  ]
}

resource "google_service_account" "signurl_account" {
  account_id   = "${local.account_id}-${random_id.random_prefix.dec}"
  display_name = "Service Account for Cloud Function to sign URLs"
}

resource "google_project_iam_custom_role" "bucket_role" {
  role_id     = "${local.role_id}_${random_id.random_prefix.dec}"
  title       = "SignURL Role"
  description = "Custom role for signing URLs"

  permissions = [
    "iam.serviceAccounts.signBlob",
    "storage.buckets.get",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get"
  ]

  stage = "GA"
}

resource "google_project_iam_binding" "service_account_binding" {
  role    = google_project_iam_custom_role.bucket_role.id
  project = var.gcp_project_id

  members = [
    "serviceAccount:${google_service_account.signurl_account.email}",
  ]
}

resource "google_project_service" "gcp_services" {
  for_each = toset(local.apis_list)
  project  = var.gcp_project_id
  service  = each.key
}

data "google_app_engine_default_service_account" "default" {
  depends_on = [
    google_cloudfunctions2_function.function
  ]
}

data "google_compute_default_service_account" "default" {
  depends_on = [
    google_cloudfunctions2_function.function
  ]
}

