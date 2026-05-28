variable "domain" {
  type        = string
  description = "deSEC domain name"
}

variable "subdomain" {
  type        = string
  description = "Subdomain label (e.g. node01 for node01.example.com)"
}

variable "ip" {
  type        = string
  description = "IPv4 address for the A record"
}

variable "ttl" {
  type        = number
  description = "DNS TTL in seconds — lower during initial provisioning, raise once stable"
  default     = 3600
}
