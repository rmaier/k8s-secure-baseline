terraform {
  required_version = ">= 1.8"

  required_providers {
    desec = {
      source  = "timofurrer/desec"
      version = "~> 0.6"
    }
  }
}

resource "desec_rrset" "a" {
  domain  = var.domain
  subname = var.subdomain
  type    = "A"
  ttl     = var.ttl
  rdata   = [var.ip]
}

resource "desec_rrset" "wildcard" {
  domain  = var.domain
  subname = "*"
  type    = "A"
  ttl     = var.ttl
  rdata   = [var.ip]
}
