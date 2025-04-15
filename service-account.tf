resource "google_service_account" "config_connector_sa" {
  account_id   = "config-connector"
  display_name = "Config Connector Service Account"
}

resource "google_project_iam_member" "config_connector_permissions" {
  for_each = toset([
    "roles/owner"
  ])
  project = "training-platform-engineer"
  role    = each.value
  member  = "serviceAccount:${google_service_account.config_connector_sa.email}"
}
