terraform {
  required_version = ">= 1.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.33"
    }
  }
}

data "google_compute_network" "this" {
  name = var.network_name
}

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_firewall" "allow" {
  for_each = var.allowed_ports

  name      = "${var.instance_name}-allow-${each.key}"
  network   = data.google_compute_network.this.self_link
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.network_tag]

  allow {
    protocol = "tcp"
    ports    = [each.value]
  }
}

resource "google_compute_instance" "this" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = [var.network_tag]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network = data.google_compute_network.this.self_link

    # Ephemeral external IPv4.
    access_config {}
  }
}
