 include {
  path = find_in_parent_folders("backend.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "file://${get_env("REPO_ROOT")}/modules/vpc"
}

inputs = merge(
  local.env_config.inputs, {
    vpc_name             = "vpc-${local.env_config.inputs.env_name}",
    address_space        = ["10.0.0.0/16"],
    public_subnet_prefix = ["10.0.1.0/24"],
    private_subnet_prefix= ["10.0.2.0/24"]
  }
)
