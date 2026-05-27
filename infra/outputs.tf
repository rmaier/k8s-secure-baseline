output "instance_name" {
  value       = google_compute_instance.vps.name
  description = "Instance name"
}

output "instance_zone" {
  value       = google_compute_instance.vps.zone
  description = "Instance zone"
}

output "instance_external_ip" {
  value       = google_compute_instance.vps.network_interface[0].access_config[0].nat_ip
  description = "Ephemeral external IPv4"
}
