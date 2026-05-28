output "fqdn" {
  description = "Fully qualified domain name for the A record"
  value       = "${var.subdomain}.${var.domain}"
}
