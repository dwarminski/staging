# staging

terraform-project/
├── live/ # Envs config (dev, staging, prod)
│ ├── dev/ # Dev env
│ │ ├── terragrunt.hcl # Main config Terragrunt
│ │ ├── vpc/ # VPC config
│ │ │ ├── terragrunt.hcl
│ │ ├── vm/ # VM config
│ │ ├── terragrunt.hcl
│ ├── staging/ # Staging env
│ ├── prod/ # Prod env
├── modules/ # Terraform modules
│ ├── vpc/ # VPC module
│ │ ├── main.tf
│ ├── vm/ # VM module
│ ├── main.tf
├── .github/workflows/ # GitHub Actions
│ ├── terraform.yml # CI/CD file
├── backend.hcl # Backend for Terraform
├── Makefile # Automate Terraform i Terragrunt
└── .gitignore # Ignore state files
