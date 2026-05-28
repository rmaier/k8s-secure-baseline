# Module: dns

Creates a deSEC A record for a subdomain using the [timofurrer/desec](https://registry.opentofu.org/providers/timofurrer/desec/latest) provider.

## Usage

```hcl
module "dns" {
  source    = "./modules/dns"
  domain    = "example.com"
  subdomain = "node01"
  ip        = google_compute_instance.vps.network_interface[0].access_config[0].nat_ip
}
```

Set `ttl = 60` in `terraform.tfvars` during initial provisioning to speed up propagation, then raise it back to 3600 once the IP is stable.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `domain` | string | — | deSEC domain name |
| `subdomain` | string | — | Subdomain label (e.g. `node01` for `node01.example.com`) |
| `ip` | string | — | IPv4 address for the A record |
| `ttl` | number | `3600` | DNS TTL in seconds |

## Outputs

| Name | Description |
|---|---|
| `fqdn` | Fully qualified domain name (`subdomain.domain`) |
