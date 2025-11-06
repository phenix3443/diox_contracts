# Makefile for Diox Contracts - Ethereum Sample
# Foundry-based Testing and Development Workflow

.PHONY: help install install-forge install-all build test test-all test-app test-integration \
        test-gas test-coverage test-debug test-verbose test-fuzz test-specific clean rebuild \
        check-forge update-deps

# Default target
.DEFAULT_GOAL := help

# Colors for terminal output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# Ensure Foundry is in PATH
export PATH := $(HOME)/.foundry/bin:$(PATH)

#==============================================================================
# Help
#==============================================================================

help: ## Display this help message
	@echo "$(BLUE)Diox Contracts - Ethereum Sample Makefile$(NC)"
	@echo "=============================================="
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make [target]"
	@echo ""
	@echo "$(GREEN)Targets:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(BLUE)%-18s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup & Installation

check-forge: ## Check if Foundry is installed
	@if ! command -v forge &> /dev/null && [ ! -f "$$HOME/.foundry/bin/forge" ]; then \
		echo "$(RED)❌ Foundry not found in PATH or ~/.foundry/bin/$(NC)"; \
		echo ""; \
		echo "$(YELLOW)💡 Install Foundry first:$(NC)"; \
		echo "  make install-forge"; \
		echo ""; \
		exit 1; \
	else \
		if command -v forge &> /dev/null; then \
			echo "$(GREEN)✅ Foundry installed:$(NC) $$(forge --version | head -n 1)"; \
		else \
			echo "$(GREEN)✅ Foundry found at ~/.foundry/bin/$(NC)"; \
		fi; \
	fi

install-forge: ## Install Foundry tools (forge, cast, anvil, chisel)
	@echo "$(BLUE)🔧 Installing Foundry...$(NC)"
	@echo ""
	@if command -v forge &> /dev/null; then \
		echo "$(GREEN)✅ Foundry is already installed$(NC)"; \
		forge --version | head -n 1; \
		exit 0; \
	fi
	@echo "$(YELLOW)Step 1: Installing foundryup...$(NC)"
	@curl -L https://foundry.paradigm.xyz | bash
	@echo ""
	@echo "$(YELLOW)Step 2: Running foundryup to install forge, cast, anvil, chisel...$(NC)"
	@if [ -f "$$HOME/.foundry/bin/foundryup" ]; then \
		$$HOME/.foundry/bin/foundryup; \
		echo ""; \
		echo "$(GREEN)✅ Foundry installed to ~/.foundry/bin/$(NC)"; \
	else \
		echo "$(RED)❌ foundryup installation failed$(NC)"; \
		exit 1; \
	fi
	@echo ""
	@if ! command -v forge &> /dev/null; then \
		echo "$(YELLOW)⚠️  Foundry installed but not in PATH$(NC)"; \
		echo "Add to your shell configuration:"; \
		echo ""; \
		echo "For bash:"; \
		echo "  echo 'export PATH=\"\$$HOME/.foundry/bin:\$$PATH\"' >> ~/.bashrc"; \
		echo "  source ~/.bashrc"; \
		echo ""; \
		echo "For zsh:"; \
		echo "  echo 'export PATH=\"\$$HOME/.foundry/bin:\$$PATH\"' >> ~/.zshrc"; \
		echo "  source ~/.zshrc"; \
		echo ""; \
	else \
		echo "$(GREEN)✅ Foundry is ready to use!$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)Next: Install project dependencies with: make install$(NC)"

install: check-forge ## Install project dependencies (requires Foundry)
	@echo "$(BLUE)📦 Installing project dependencies...$(NC)"
	@if [ ! -d "lib/forge-std" ]; then \
		forge install foundry-rs/forge-std; \
		echo "$(GREEN)✅ Dependencies installed$(NC)"; \
	else \
		echo "$(GREEN)✅ Dependencies already installed$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)🎉 Installation complete!$(NC)"
	@echo "You can now run tests with: $(BLUE)make test$(NC)"

install-all: install-forge install ## Install Foundry and project dependencies (one-command setup)
	@echo "$(GREEN)✅ Everything installed! Ready to use.$(NC)"

update-deps: ## Update all dependencies
	@echo "$(BLUE)🔄 Updating dependencies...$(NC)"
	@forge update
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

##@ Building

build: ## Compile contracts
	@echo "$(BLUE)🔨 Compiling contracts...$(NC)"
	@forge build
	@echo "$(GREEN)✅ Compilation complete$(NC)"

clean: ## Clean build artifacts
	@echo "$(BLUE)🧹 Cleaning build artifacts...$(NC)"
	@forge clean
	@rm -rf cache out
	@echo "$(GREEN)✅ Clean complete$(NC)"

rebuild: clean build ## Clean and rebuild

##@ Testing

test: ## Run all tests with normal verbosity
	@echo "$(BLUE)🧪 Running all tests...$(NC)"
	@forge test -vv

test-all: ## Run all tests (same as test)
	@echo "$(BLUE)🧪 Running all tests...$(NC)"
	@forge test -vv

test-app: ## Run AppContract tests only
	@echo "$(BLUE)🧪 Running AppContract tests...$(NC)"
	@forge test --match-contract AppContractTest -vv

test-integration: ## Run integration tests only
	@echo "$(BLUE)🧪 Running integration tests...$(NC)"
	@forge test --match-contract FullIntegrationTest -vv

test-verbose: ## Run tests with maximum verbosity
	@echo "$(BLUE)🧪 Running tests with maximum verbosity...$(NC)"
	@forge test -vvvv

test-debug: ## Run tests with trace output
	@echo "$(BLUE)🔍 Running tests with trace output...$(NC)"
	@forge test -vvvvv

test-fuzz: ## Run fuzzing tests
	@echo "$(BLUE)🎲 Running fuzzing tests...$(NC)"
	@forge test --match-test testFuzz -vv

test-gas: ## Run tests with gas reporting
	@echo "$(BLUE)⛽ Running tests with gas report...$(NC)"
	@forge test --gas-report

test-coverage: ## Generate test coverage report
	@echo "$(BLUE)📊 Generating coverage report...$(NC)"
	@forge coverage

test-coverage-lcov: ## Generate coverage in lcov format
	@echo "$(BLUE)📊 Generating coverage report (lcov)...$(NC)"
	@forge coverage --report lcov

test-specific: ## Run a specific test (usage: make test-specific TEST=test_SendMessage)
	@if [ -z "$(TEST)" ]; then \
		echo "$(RED)❌ Please specify TEST variable$(NC)"; \
		echo "$(YELLOW)Usage: make test-specific TEST=test_SendMessage$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🧪 Running test: $(TEST)$(NC)"
	@forge test --match-test $(TEST) -vv


