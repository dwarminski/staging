locals {
  env_name = "staging"
  location = "westeurope"
}

inputs = {
  env_name              = local.env_name
  location              = local.location
  resource_group_name   = "rg-${local.env_name}"
  create_ddos_protection = false
}
