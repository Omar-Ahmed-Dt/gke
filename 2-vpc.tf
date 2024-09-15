# Enable the necessary Google Cloud services for compute and container (GKE)
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

# Create a custom VPC network
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
resource "google_compute_network" "main" {
  name                            = "main-network"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false # No auto subnet creation for more control
  mtu                             = 1460  # Maximum Transmission Unit for network
  delete_default_routes_on_create = false # Keep default routes

  # Ensure the network is created after the services are enabled
  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}
