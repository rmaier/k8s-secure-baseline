output "instance_name" {
  value       = module.vps.instance_name
  description = "Instance name"
}

output "instance_zone" {
  value       = module.vps.instance_zone
  description = "Instance zone"
}

output "instance_external_ip" {
  value       = module.vps.external_ip
  description = "Ephemeral external IPv4"
}

output "fqdn" {
  value       = module.dns.fqdn
  description = "Fully qualified domain name pointing to the VPS"
}
