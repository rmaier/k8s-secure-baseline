# Infra (OpenTofu + Terragrunt)

Provisions the GCP VPS and DNS record. Environments live under `envs/`, shared modules under `modules/`.

```
infra/
├── root.hcl                # root: remote state config (GCS — see inline instructions)
├── modules/
│   ├── gcp-vps/            # Compute Engine instance + firewall rules
│   └── dns/                # deSEC A record via timofurrer/desec
└── envs/
    └── gcp-vps/            # single GCP VM running kubeadm
        ├── terragrunt.hcl
        ├── main.tf
        └── terraform.tfvars (gitignored — copy from terraform.tfvars.example)
```

## Auth

Uses Application Default Credentials (ADC):

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project <PROJECT_ID>
```

## Run with Terragrunt (recommended)

```bash
cd infra/envs/gcp-vps
terragrunt init
terragrunt plan -var-file=terraform.tfvars
terragrunt apply -var-file=terraform.tfvars
```

## Run with OpenTofu directly (no Terragrunt installed)

Local state only — no remote backend:

```bash
cd infra/envs/gcp-vps
tofu init
tofu plan -var-file=terraform.tfvars
tofu apply -var-file=terraform.tfvars
```

## Remote state

Remote state (GCS backend) is stubbed in `infra/terragrunt.hcl`. To enable:

```bash
# Create the bucket
gcloud storage buckets create gs://<BUCKET_NAME> \
  --project=<PROJECT_ID> \
  --location=europe-southwest1 \
  --uniform-bucket-level-access
```

Then uncomment and fill in the `remote_state` block in `infra/root.hcl`.

## Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in the values.
`desec_token` should be set via the `TF_VAR_desec_token` environment variable — never commit it.

```bash
export TF_VAR_desec_token=<your-token>
```
