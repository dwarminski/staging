include {
  path = find_in_parent_folders("backend.hcl")
}

locals {
  env_config = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  computed_subnet_ids = {
    public  = "/subscriptions/${get_env("ARM_SUBSCRIPTION_ID")}/resourceGroups/${local.env_config.inputs.resource_group_name}/providers/Microsoft.Network/virtualNetworks/vpc-${local.env_config.inputs.env_name}/subnets/subnet-${local.env_config.inputs.env_name}-public",
    private = "/subscriptions/${get_env("ARM_SUBSCRIPTION_ID")}/resourceGroups/${local.env_config.inputs.resource_group_name}/providers/Microsoft.Network/virtualNetworks/vpc-${local.env_config.inputs.env_name}/subnets/subnet-${local.env_config.inputs.env_name}-private"
  }
}

dependency "vpc" {
  config_path = "${get_env("REPO_ROOT")}/live/staging/vpc"
  mock_outputs = {
    subnet_ids = local.computed_subnet_ids
  }
}

terraform {
  source = "file://${get_env("REPO_ROOT")}/modules/vm"
}

inputs = merge(
  local.env_config.inputs, {
    vm_name   = "vm-${local.env_config.inputs.env_name}",
    subnet_id = dependency.vpc.outputs.subnet_ids["public"]
  }
)
