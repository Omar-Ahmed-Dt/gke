# Allow SSH traffic
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow HTTP (port 80) and HTTPS (port 443) traffic
# resource "google_compute_firewall" "allow-http-https" {
#   name    = "allow-http-https"
#   network = google_compute_network.main.name

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]
#   }

#   # Allow traffic from anywhere
#   source_ranges = ["0.0.0.0/0"]
  
  # Optional: You can add target tags if you want to restrict the rule to specific instances (e.g., GKE nodes)
  # target_tags = ["gke-cluster-tag"] # Replace with your GKE node tag if needed
# }
