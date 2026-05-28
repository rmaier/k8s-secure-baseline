# Module: vps

Provisions a single GCP Compute Engine instance with Ubuntu 24.04 LTS and a set of ingress firewall rules.

## Usage

```hcl
module "vps" {
  source = "./modules/vps"

  instance_name = "my-vps"
  zone          = "europe-southwest1-a"
}
```

Override `allowed_ports` to open additional ports or restrict defaults:

```hcl
module "vps" {
  source = "./modules/vps"

  instance_name = "my-vps"
  zone          = "europe-southwest1-a"

  allowed_ports = {
    ssh            = "22"
    http           = "80"
    https          = "443"
    kube-apiserver = "6443"
  }
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `instance_name` | string | — | Compute Engine instance name |
| `zone` | string | — | GCP zone |
| `machine_type` | string | `e2-medium` | GCE machine type |
| `network_name` | string | `default` | VPC network name |
| `network_tag` | string | `vps` | Network tag applied to the instance and matched by firewall rules |
| `boot_disk_size_gb` | number | `30` | Boot disk size in GB |
| `boot_disk_type` | string | `pd-balanced` | Boot disk type |
| `allowed_ports` | map(string) | `{ssh=22, http=80, https=443, kube-apiserver=6443}` | Firewall rules — map of name suffix to TCP port |

## Outputs

| Name | Description |
|---|---|
| `external_ip` | Ephemeral external IPv4 of the instance |
| `instance_name` | Compute Engine instance name |
| `instance_zone` | Zone the instance is deployed in |
