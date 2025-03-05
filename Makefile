# Variables
LIVE_DIR=live
MODULES_DIR=modules
BACKEND_CONFIG=backend.hcl
ENVIRONMENTS=dev staging prod

# Error: Resource already exists, import into tfstate
# Reason: Tg copies files into .tg-cache
FIND_TG = find $(LIVE_DIR) -path "*/.terragrunt-cache/*" -prune -o -type f -name "terragrunt.hcl" -print

.PHONY: init-structure
define create_dirs
	@echo "Creating directory structure..."
	@mkdir -p $(LIVE_DIR) $(MODULES_DIR)
	@for env in $(ENVIRONMENTS); do \
		mkdir -p $(LIVE_DIR)/$$env/vpc $(LIVE_DIR)/$$env/vm; \
		touch $(LIVE_DIR)/$$env/terragrunt.hcl; \
		touch $(LIVE_DIR)/$$env/vpc/terragrunt.hcl; \
		touch $(LIVE_DIR)/$$env/vm/terragrunt.hcl; \
	done; \
	mkdir -p $(MODULES_DIR)/vpc $(MODULES_DIR)/vm; \
	touch $(MODULES_DIR)/vpc/main.tf $(MODULES_DIR)/vm/main.tf; \
	touch $(BACKEND_CONFIG); \
	echo "✅ Directory structure created!"
endef

init-structure:
	$(create_dirs)

.PHONY: terragrunt-init
terragrunt-init:
	@echo "Initializing Terragrunt..."
	@$(FIND_TG) | while read file; do \
		dir=$$(dirname $$file); \
		echo "Initializing in $$dir..."; \
		(cd $$dir && terragrunt init -reconfigure) || exit 1; \
	done
	@echo "✅ Terragrunt Initialized in all directories!"

.PHONY: terragrunt-validate
terragrunt-validate:
	@echo "Validating Terragrunt..."
	@$(FIND_TG) | while read file; do \
		dir=$$(dirname $$file); \
		echo "Validating in $$dir..."; \
		(cd $$dir && terragrunt validate) || exit 1; \
	done
	@echo "✅ Terragrunt code is valid in all directories!"

.PHONY: terragrunt-plan
terragrunt-plan:
	@echo "Generating Terragrunt plan..."
	@$(FIND_TG) | while read file; do \
		dir=$$(dirname $$file); \
		echo "Planning in $$dir..."; \
		(cd $$dir && terragrunt plan) || exit 1; \
	done
	@echo "✅ Terragrunt plan is ready in all directories!"

.PHONY: terragrunt-apply
terragrunt-apply:
	@echo "🚀 Applying Terragrunt changes..."
	@$(FIND_TG) | while read file; do \
		dir=$$(dirname $$file); \
		echo "Applying in $$dir..."; \
		(cd $$dir && terragrunt apply -auto-approve) || exit 1; \
	done
	@echo "✅ Terragrunt changes applied in all directories!"

.PHONY: terragrunt-destroy-vm
terragrunt-destroy-vm:
	@echo "🛑 Destroying VM modules..."
	@find $(LIVE_DIR) -path "*/vm/terragrunt.hcl" -print | while read file; do \
		dir=$$(dirname $$file); \
		echo "Destroying VM in $$dir..."; \
		(cd $$dir && yes | terragrunt destroy -auto-approve) || exit 1; \
	done
	@echo "✅ VM modules destroyed!"

.PHONY: terragrunt-destroy-vpc
terragrunt-destroy-vpc:
	@echo "🛑 Destroying VPC modules..."
	@find $(LIVE_DIR) -path "*/vpc/terragrunt.hcl" -print | while read file; do \
		dir=$$(dirname $$file); \
		echo "Destroying VPC in $$dir..."; \
		(cd $$dir && yes | terragrunt destroy -auto-approve) || exit 1; \
	done
	@echo "✅ VPC modules destroyed!"

.PHONY: terragrunt-destroy
terragrunt-destroy: terragrunt-destroy-vm terragrunt-destroy-vpc
	@echo "✅ All Terragrunt resources destroyed in proper order!"
# Inject yes into destroy to avoid "Detected dependent modules"
# Tg looses order of deleting

.PHONY: del-structure
del-structure:
	@echo "Deleting directory structure..."
	@rm -rf $(LIVE_DIR) $(MODULES_DIR) $(BACKEND_CONFIG)
	@echo "✅ Directory structure deleted!"
