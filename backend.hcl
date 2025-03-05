remote_state {
  backend = "azurerm"
  config = {
    storage_account_name  = "tfstate0024"
    container_name        = "tfstate"
    key                   = "${path_relative_to_include()}/terraform.tfstate"
    resource_group_name   = "terraform-rg"
  }
}

# Optionally: generate a provider.tf in each module so you don’t have
# to define the provider manually in your module code:
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  features {}
}
EOF
}
