variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "instance_name" {
  type        = string
  description = "Compute Engine instance name"
}

variable "machine_type" {
  type        = string
  description = "GCE machine type"
  default     = "e2-medium"
}

variable "boot_disk_size_gb" {
  type        = number
  description = "Boot disk size in GB"
  default     = 30
}

variable "boot_disk_type" {
  type        = string
  description = "Boot disk type (e.g. pd-balanced, pd-ssd, pd-standard)"
  default     = "pd-balanced"
}

variable "network_name" {
  type        = string
  description = "VPC network name (default VPC is 'default')"
  default     = "default"
}

variable "network_tag" {
  type        = string
  description = "Network tag applied to the instance and used by firewall rules"
  default     = "vps"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "europe-southwest1"
}

variable "zone" {
  type        = string
  description = "Default zone"
  default     = "europe-southwest1-a"
}
