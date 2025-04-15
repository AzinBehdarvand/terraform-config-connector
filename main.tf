resource "google_container_cluster" "autopilot_cluster" {
  name     = "config-connector-cluster"
  location = "europe-west2"

  enable_autopilot = true
}
