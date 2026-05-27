terraform {
  required_version = ">= 1.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.33"
    }
    desec = {
      source  = "timofurrer/desec"
      version = "~> 0.6"
    }
  }
}
