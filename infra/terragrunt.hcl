# Root Terragrunt configuration — inherited by all environments via find_in_parent_folders().
#
# Remote state — GCS backend.
# Create the bucket before enabling this block:
#
#   gcloud storage buckets create gs://<BUCKET_NAME> \
#     --project=<PROJECT_ID> \
#     --location=europe-southwest1 \
#     --uniform-bucket-level-access
#
# Then uncomment:
#
# remote_state {
#   backend = "gcs"
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
#   config = {
#     bucket  = "<BUCKET_NAME>"
#     prefix  = "${path_relative_to_include()}/terraform.tfstate"
#     project = "<PROJECT_ID>"
#   }
# }
