terraform {
  backend "gcs" {
    bucket = "enkidu-tf-state-staging"  # Replace with your GCS bucket name
    prefix = "terraform/state"          # Path to store the Terraform state file
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"  # You can specify a different version if needed
    }
  }
}
# Google Cloud Provider Configuration
provider "google" {
  project = "nice-hydra-435514-e8"  # Replace with your actual project ID
  region  = "africa-south1"         # Set your preferred region
}

# Data source to retrieve the Google Cloud client configuration
data "google_client_config" "default" {}

# Get the GKE cluster details
data "google_container_cluster" "primary" {
  depends_on = [google_container_cluster.primary]  # Ensure cluster is created first
  name     = google_container_cluster.primary.name
  location = google_container_cluster.primary.location
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = data.google_container_cluster.primary.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  # load_config_file       = false
  # depends_on = [google_container_cluster.primary]
}

# Helm Provider Configuration
provider "helm" {
  kubernetes {
    # host                   = data.google_container_cluster.primary.endpoint
    # token                  = data.google_client_config.default.access_token
    host                   = google_container_cluster.primary.endpoint
    token                  = data.google_client_config.default.access_token
    # token                  = google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
    # load_config_file       = false
  }
}
