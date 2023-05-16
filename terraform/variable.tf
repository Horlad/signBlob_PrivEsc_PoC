variable "gcp_region" {
  description = "GCP region"
  default     = "us-central1"
  type        = string

}

variable "gcp_project_id" {
  description = "A UUID for environment-related resources"
  type        = string
}