module "vps" {
  source = "./modules/vps"

  instance_name     = var.instance_name
  machine_type      = var.machine_type
  zone              = var.zone
  network_name      = var.network_name
  network_tag       = var.network_tag
  boot_disk_size_gb = var.boot_disk_size_gb
  boot_disk_type    = var.boot_disk_type
}

module "dns" {
  source = "./modules/dns"

  domain    = var.domain
  subdomain = var.subdomain
  ip        = module.vps.external_ip
}
