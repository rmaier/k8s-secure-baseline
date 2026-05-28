output "external_ip" {
  description = "Ephemeral external IPv4 of the instance"
  value       = google_compute_instance.this.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
  description = "Compute Engine instance name"
  value       = google_compute_instance.this.name
}

output "instance_zone" {
  description = "Zone the instance is deployed in"
  value       = google_compute_instance.this.zone
}
