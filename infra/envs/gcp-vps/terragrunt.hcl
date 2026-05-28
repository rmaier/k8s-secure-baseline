include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Copy the entire infra/ tree to the Terragrunt cache so that relative
# module paths (../../modules/...) resolve correctly from within the cache.
terraform {
  source = "${get_repo_root()}/infra//envs/gcp-vps"
}
