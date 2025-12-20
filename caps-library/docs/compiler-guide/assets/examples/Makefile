# Makefile for CAPS-to-Skills Compiler
# Automates common compilation tasks

.PHONY: help validate compile clean list test all

# Variables
COMPILER := caps-library/scripts/caps-to-skills.sh
PLAYBOOKS_DIR := caps-library/playbooks
SKILLS_DIR := .claude/skills

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help:
	@echo "CAPS-to-Skills Compiler - Makefile Targets"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  help        Show this help message"
	@echo "  validate    Validate all playbooks without compiling"
	@echo "  compile     Compile all playbooks to skills"
	@echo "  clean       Remove all generated skills"
	@echo "  list        List all available playbooks"
	@echo "  test        Run validation tests on all playbooks"
	@echo "  all         Clean, validate, and compile (full rebuild)"
	@echo ""
	@echo "Single playbook targets:"
	@echo "  compile-<name>  Compile specific playbook (e.g., make compile-hello-world)"
	@echo "  validate-<name> Validate specific playbook (e.g., make validate-hello-world)"

validate:
	@echo "$(YELLOW)Validating all CAPS playbooks...$(NC)"
	@for dir in $(PLAYBOOKS_DIR)/*/; do \
		playbook=$$(basename $$dir); \
		echo "Validating: $$playbook"; \
		bash $(COMPILER) $$playbook --validate --dry-run || exit 1; \
	done
	@echo "$(GREEN)All playbooks validated successfully!$(NC)"

compile:
	@echo "$(YELLOW)Compiling all CAPS playbooks...$(NC)"
	@for dir in $(PLAYBOOKS_DIR)/*/; do \
		playbook=$$(basename $$dir); \
		echo "Compiling: $$playbook"; \
		bash $(COMPILER) $$playbook --validate || exit 1; \
	done
	@echo "$(GREEN)All playbooks compiled successfully!$(NC)"

clean:
	@echo "$(YELLOW)Cleaning generated skills...$(NC)"
	@rm -rf $(SKILLS_DIR)/*
	@echo "$(GREEN)All skills removed$(NC)"

list:
	@echo "Available CAPS playbooks:"
	@for dir in $(PLAYBOOKS_DIR)/*/; do \
		playbook=$$(basename $$dir); \
		echo "  - $$playbook"; \
	done

test: validate
	@echo "$(GREEN)All tests passed!$(NC)"

all: clean validate compile
	@echo "$(GREEN)Full rebuild complete!$(NC)"

# Dynamic targets for individual playbooks
compile-%:
	@playbook=$*; \
	echo "$(YELLOW)Compiling playbook: $$playbook$(NC)"; \
	bash $(COMPILER) $$playbook --validate

validate-%:
	@playbook=$*; \
	echo "$(YELLOW)Validating playbook: $$playbook$(NC)"; \
	bash $(COMPILER) $$playbook --validate --dry-run

# Example usage:
# make compile-hello-world     # Compile hello-world playbook
# make validate-kafka-k8s-setup  # Validate kafka-k8s-setup playbook
