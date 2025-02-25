# Variables
LIVE_DIR=live
MODULES_DIR=modules
BACKEND_CONFIG=backend.hcl

# Environments
ENVIRONMENTS=dev staging prod

# Create directory structure
.PHONY: init-structure
init-structure:
	@echo "Creating directory structure..."
	@mkdir -p $(LIVE_DIR) $(MODULES_DIR)
	@for env in $(ENVIRONMENTS); do \
		mkdir -p $(LIVE_DIR)/$$env/vpc $(LIVE_DIR)/$$env/vm; \
		touch $(LIVE_DIR)/$$env/terragrunt.hcl; \
		touch $(LIVE_DIR)/$$env/vpc/terragrunt.hcl; \
		touch $(LIVE_DIR)/$$env/vm/terragrunt.hcl; \
	done
	@mkdir -p $(MODULES_DIR)/vpc $(MODULES_DIR)/vm
	@touch $(MODULES_DIR)/vpc/main.tf $(MODULES_DIR)/vm/main.tf
	@touch $(BACKEND_CONFIG)
	@echo "✅ Directory structure created!"

# Terraform & Terragrunt
.PHONY: terraform-init terragrunt-init
terraform-init:
	@echo "Initializing Terraform..."
	cd $(LIVE_DIR)/dev && terraform init -backend-config=../../$(BACKEND_CONFIG)
	@echo "✅ Terraform Initialized!"

terragrunt-init:
	@echo "Initializing Terragrunt..."
	cd $(LIVE_DIR)/dev && terragrunt init
	@echo "✅ Terragrunt Initialized!"

.PHONY: terraform-validate terragrunt-validate
terraform-validate:
	@echo "Validating Terraform..."
	cd $(LIVE_DIR)/dev && terraform validate
	@echo "✅ Terraform code is valid!"

terragrunt-validate:
	@echo "Validating Terragrunt..."
	cd $(LIVE_DIR)/dev && terragrunt validate
	@echo "✅ Terragrunt code is valid!"

.PHONY: terraform-plan terragrunt-plan
terraform-plan:
	@echo "Generating Terraform plan..."
	cd $(LIVE_DIR)/dev && terraform plan -out=tfplan
	@echo "✅ Terraform plan is ready!"

terragrunt-plan:
	@echo "Generating Terragrunt plan..."
	cd $(LIVE_DIR)/dev && terragrunt plan
	@echo "✅ Terragrunt plan is ready!"

.PHONY: terraform-apply terragrunt-apply
terraform-apply:
	@echo "🚀 Applying Terraform changes..."
	cd $(LIVE_DIR)/dev && terraform apply -auto-approve tfplan
	@echo "✅ Terraform changes applied!"

terragrunt-apply:
	@echo "🚀 Applying Terragrunt changes..."
	cd $(LIVE_DIR)/dev && terragrunt apply -auto-approve
	@echo "✅ Terragrunt changes applied!"

.PHONY: terraform-destroy terragrunt-destroy
terraform-destroy:
	@echo "🛑 Destroying Terraform resources..."
	cd $(LIVE_DIR)/dev && terraform destroy -auto-approve
	@echo "✅ Terraform resources destroyed!"

terragrunt-destroy:
	@echo "🛑 Destroying Terragrunt resources..."
	cd $(LIVE_DIR)/dev && terragrunt destroy -auto-approve
	@echo "✅ Terragrunt resources destroyed!"

.PHONY: del-structure
del-structure:
	@echo "Deleting directory structure..."
	rm -rf $(LIVE_DIR) $(MODULES_DIR) $(BACKEND_CONFIG)
	@echo "✅ Directory structure deleted!"