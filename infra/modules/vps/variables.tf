variable "instance_name" {
  type        = string
  description = "Compute Engine instance name"
}

variable "machine_type" {
  type        = string
  description = "GCE machine type"
  default     = "e2-medium"
}

variable "zone" {
  type        = string
  description = "GCP zone"
}

variable "network_name" {
  type        = string
  description = "VPC network name"
  default     = "default"
}

variable "network_tag" {
  type        = string
  description = "Network tag applied to the instance and matched by firewall rules"
  default     = "vps"
}

variable "boot_disk_size_gb" {
  type        = number
  description = "Boot disk size in GB"
  default     = 30
}

variable "boot_disk_type" {
  type        = string
  description = "Boot disk type (pd-balanced, pd-ssd, pd-standard)"
  default     = "pd-balanced"
}

variable "allowed_ports" {
  type        = map(string)
  description = "Firewall rules to open — map of rule name suffix to TCP port"
  default = {
    ssh            = "22"
    http           = "80"
    https          = "443"
    kube-apiserver = "6443"
  }
}
