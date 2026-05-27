# Infra (OpenTofu)

Bootstrap OpenTofu config for provisioning on GCP.

## Auth (Local)

Uses Application Default Credentials (ADC) from gcloud.

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project project-19f7eed5-b04a-472c-b23

# From repo root:

tofu -chdir=infra init
tofu -chdir=infra validate
tofu -chdir=infra plan -var 'project_id=project-19f7eed5-b04a-472c-b23'
```

Local state will appear after the first apply as `infra/terraform.tfstate`.
