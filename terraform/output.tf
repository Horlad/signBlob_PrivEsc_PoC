output "function_uri" {
  value = google_cloudfunctions2_function.function.service_config[0].uri
}

output "default_app_engine_account" {
  value = data.google_app_engine_default_service_account.default.email
}

output "default_account" {
  value = data.google_compute_default_service_account.default.email
}