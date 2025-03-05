# Terragrunt multi-env

Robust multi-environment management using Terragrunt. Each environment is fully isolated through dedicated configuration files, unique resource naming, and the use of absolute module paths (via the REPO_ROOT environment variable) ensures consistent behavior regardless of Terragrunt's cache.

## Structure

```bash
staging/
├── live/
│   ├── dev/
│   │   └── env.hcl/
│   │       ├── vm/
│   │       │   └── terragrunt.hcl
│   │       └── vpc/
│   │           └── terragrunt.hcl
│   ├── prod/
│   │   └── env.hcl/
│   │       ├── vm/
│   │       │   └── terragrunt.hcl
│   │       └── vpc/
│   │           └── terragrunt.hcl
│   └── staging/
│       └── env.hcl/
│           ├── vm/
│           │   └── terragrunt.hcl
│           └── vpc/
│               └── terragrunt.hcl
└── modules/
    ├── vm/
    │   ├── main.tf
    │   ├── output.tf
    │   └── backend.tf
    └── vpc/
        ├── main.tf
        ├── output.tf
        └── backend.tf
Makefile
backend.hcl
```

## Prerequisites

- **Terraform** (v1.0+ recommended)
- **Terragrunt** (v0.35+ recommended)
- **Azure CLI** or a valid service principal with credentials set via environment variables:
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`
  - `ARM_TENANT_ID`
- Set an environment variable for your repository root:
  ```bash
  export REPO_ROOT="/home/<user>/<destination>/staging"
  ```

## How to usage

The Makefile provides targets to initialize, validate, plan, apply, and destroy infrastructure across all environments. The Makefile is designed to ignore files within .terragrunt-cache so that only your real configuration files in live/ are processed.

### Directories

```bash
make init-structure

```

### Initialize

```bash
make terragrunt-init

```

### Validate

```bash
make terragrunt-validate

```

### Plan

```bash
make terragrunt-plan

```

### Apply

```bash
make terragrunt-apply

```

### Clean up

```bash
make terragrunt-destroy
make del-structure

```

## Roadmap short-term

- CI/CD GitHub Actions

- TerraTest

- Prometheus/Grafana in prod env

## Roadmap long-term

- Managing secrets via HashiCorp Vault

- Change CI/CD

## Running Tests

TBA

```bash
  go test my_tests.go
```
