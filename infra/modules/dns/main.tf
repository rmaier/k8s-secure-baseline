terraform {
  required_version = ">= 1.8"

  required_providers {
    desec = {
      source  = "timofurrer/desec"
      version = "~> 0.6"
    }
  }
}

variable "domain" {
  type        = string
  description = "deSEC domain name"
}

variable "subdomain" {
  type        = string
  description = "deSEC sub domain name (e.g. example for example.dedyn.io)"
}


variable "ip" {
  type        = string
  description = "IPv4 address for the apex A record"
}

resource "desec_rrset" "a" {
  domain  = var.domain
  subname = var.subdomain
  type    = "A"
  ttl     = 3600
  rdata   = [var.ip]
}
