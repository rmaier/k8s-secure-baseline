provider "google" {
  # Uses Application Default Credentials (ADC) from gcloud by default.
  # https://cloud.google.com/docs/authentication/provide-credentials-adc
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "desec" {
  api_token = var.desec_token
}
