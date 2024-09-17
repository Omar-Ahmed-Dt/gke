output "cluster_endpoint" {
  value = data.google_container_cluster.primary.endpoint

}

output "access_token" {
  value = data.google_client_config.default.access_token
  sensitive = true

}
