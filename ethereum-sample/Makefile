# Makefile for Diox Contracts - Ethereum Sample
# Foundry-based Testing and Development Workflow

.PHONY: help install build test test-all test-app test-integration test-gas test-coverage \
        test-debug test-verbose test-fuzz clean fmt lint snapshot deploy-local \
        check-forge update-deps

# Default target
.DEFAULT_GOAL := help

# Colors for terminal output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# Smart forge command detection
# First try to find forge in PATH, then fall back to ~/.foundry/bin/forge
FORGE := $(shell command -v forge 2>/dev/null || echo "$(HOME)/.foundry/bin/forge")

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
		echo "$(YELLOW)💡 Run this to install everything:$(NC)"; \
		echo "  make install"; \
		echo ""; \
		exit 1; \
	else \
		if command -v forge &> /dev/null; then \
			echo "$(GREEN)✅ Foundry installed:$(NC) $$(forge --version | head -n 1)"; \
		else \
			echo "$(GREEN)✅ Foundry found at ~/.foundry/bin/$(NC)"; \
		fi; \
	fi

install: ## Install Foundry and project dependencies (one-command setup)
	@echo "$(BLUE)🚀 Starting installation...$(NC)"
	@echo ""
	@# Check if forge is available
	@if ! command -v forge &> /dev/null && [ ! -f "$$HOME/.foundry/bin/forge" ]; then \
		echo "$(YELLOW)📦 Foundry not found, installing...$(NC)"; \
		echo ""; \
		echo "$(YELLOW)Step 1: Installing foundryup...$(NC)"; \
		curl -L https://foundry.paradigm.xyz | bash; \
		echo ""; \
		echo "$(YELLOW)Step 2: Installing Foundry tools...$(NC)"; \
		$$HOME/.foundry/bin/foundryup; \
		echo ""; \
		echo "$(GREEN)✅ Foundry installed to ~/.foundry/bin/$(NC)"; \
		echo ""; \
	elif [ -f "$$HOME/.foundry/bin/forge" ]; then \
		echo "$(GREEN)✅ Foundry found at ~/.foundry/bin/$(NC)"; \
	else \
		echo "$(GREEN)✅ Foundry is installed$(NC)"; \
	fi
	@echo ""
	@echo "$(BLUE)📦 Installing project dependencies...$(NC)"
	@# Use forge from PATH or from ~/.foundry/bin
	@if command -v forge &> /dev/null; then \
		FORGE_CMD=forge; \
	elif [ -f "$$HOME/.foundry/bin/forge" ]; then \
		FORGE_CMD=$$HOME/.foundry/bin/forge; \
	else \
		echo "$(RED)❌ Cannot find forge command$(NC)"; \
		echo "$(YELLOW)Please add Foundry to PATH:$(NC)"; \
		echo "  export PATH=\"\$$HOME/.foundry/bin:\$$PATH\""; \
		exit 1; \
	fi; \
	if [ ! -d "lib/forge-std" ]; then \
		$$FORGE_CMD install foundry-rs/forge-std --no-commit; \
		echo "$(GREEN)✅ Dependencies installed$(NC)"; \
	else \
		echo "$(GREEN)✅ Dependencies already installed$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)🎉 Installation complete!$(NC)"
	@echo ""
	@if ! command -v forge &> /dev/null; then \
		echo "$(YELLOW)⚠️  Note: Foundry is not in your PATH$(NC)"; \
		echo "Add it to your shell configuration:"; \
		echo ""; \
		echo "For bash:"; \
		echo "  echo 'export PATH=\"\$$HOME/.foundry/bin:\$$PATH\"' >> ~/.bashrc"; \
		echo "  source ~/.bashrc"; \
		echo ""; \
		echo "For zsh:"; \
		echo "  echo 'export PATH=\"\$$HOME/.foundry/bin:\$$PATH\"' >> ~/.zshrc"; \
		echo "  source ~/.zshrc"; \
		echo ""; \
		echo "Or use Foundry with full path: ~/.foundry/bin/forge"; \
		echo ""; \
	fi
	@echo "$(GREEN)You can now run tests with: make test$(NC)"

install-deps: check-forge ## Install only project dependencies (requires Foundry)
	@echo "$(BLUE)📦 Installing project dependencies...$(NC)"
	@if [ ! -d "lib/forge-std" ]; then \
		$(FORGE) install foundry-rs/forge-std --no-commit; \
		echo "$(GREEN)✅ Dependencies installed$(NC)"; \
	else \
		echo "$(GREEN)✅ Dependencies already installed$(NC)"; \
	fi

update-deps: ## Update all dependencies
	@echo "$(BLUE)🔄 Updating dependencies...$(NC)"
	@$(FORGE) update
	@echo "$(GREEN)✅ Dependencies updated$(NC)"

##@ Building

build: ## Compile contracts
	@echo "$(BLUE)🔨 Compiling contracts...$(NC)"
	@if ! $(FORGE) --version &> /dev/null; then \
		echo "$(RED)❌ Cannot run forge. Try:$(NC)"; \
		echo "  1. Run: make install"; \
		echo "  2. Or add to PATH: export PATH=\"\$$HOME/.foundry/bin:\$$PATH\""; \
		exit 1; \
	fi
	@$(FORGE) build
	@echo "$(GREEN)✅ Compilation complete$(NC)"

clean: ## Clean build artifacts
	@echo "$(BLUE)🧹 Cleaning build artifacts...$(NC)"
	@$(FORGE) clean
	@rm -rf cache out
	@echo "$(GREEN)✅ Clean complete$(NC)"

rebuild: clean build ## Clean and rebuild

##@ Testing

test: ## Run all tests with normal verbosity
	@echo "$(BLUE)🧪 Running all tests...$(NC)"
	@if ! $(FORGE) --version &> /dev/null; then \
		echo "$(RED)❌ Cannot run forge. Try:$(NC)"; \
		echo "  1. Run: make install"; \
		echo "  2. Or add to PATH: export PATH=\"\$$HOME/.foundry/bin:\$$PATH\""; \
		exit 1; \
	fi
	@$(FORGE) test -vv

test-all: ## Run all tests (same as test)
	@echo "$(BLUE)🧪 Running all tests...$(NC)"
	@$(FORGE) test -vv

test-app: ## Run AppContract tests only
	@echo "$(BLUE)🧪 Running AppContract tests...$(NC)"
	@$(FORGE) test --match-contract AppContractTest -vv

test-integration: ## Run integration tests only
	@echo "$(BLUE)🧪 Running integration tests...$(NC)"
	@$(FORGE) test --match-contract FullIntegrationTest -vv

test-verbose: ## Run tests with maximum verbosity
	@echo "$(BLUE)🧪 Running tests with maximum verbosity...$(NC)"
	@$(FORGE) test -vvvv

test-debug: ## Run tests with trace output
	@echo "$(BLUE)🔍 Running tests with trace output...$(NC)"
	@$(FORGE) test -vvvvv

test-fuzz: ## Run fuzzing tests
	@echo "$(BLUE)🎲 Running fuzzing tests...$(NC)"
	@$(FORGE) test --match-test testFuzz -vv

test-gas: ## Run tests with gas reporting
	@echo "$(BLUE)⛽ Running tests with gas report...$(NC)"
	@$(FORGE) test --gas-report

test-coverage: ## Generate test coverage report
	@echo "$(BLUE)📊 Generating coverage report...$(NC)"
	@$(FORGE) coverage

test-coverage-lcov: ## Generate coverage in lcov format
	@echo "$(BLUE)📊 Generating coverage report (lcov)...$(NC)"
	@$(FORGE) coverage --report lcov

test-specific: ## Run a specific test (usage: make test-specific TEST=test_SendMessage)
	@if [ -z "$(TEST)" ]; then \
		echo "$(RED)❌ Please specify TEST variable$(NC)"; \
		echo "$(YELLOW)Usage: make test-specific TEST=test_SendMessage$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🧪 Running test: $(TEST)$(NC)"
	@$(FORGE) test --match-test $(TEST) -vv

##@ Code Quality

fmt: ## Format code
	@echo "$(BLUE)✨ Formatting code...$(NC)"
	@$(FORGE) fmt
	@echo "$(GREEN)✅ Formatting complete$(NC)"

fmt-check: ## Check code formatting
	@echo "$(BLUE)🔍 Checking code formatting...$(NC)"
	@$(FORGE) fmt --check

lint: fmt-check ## Run linter (same as fmt-check)

snapshot: ## Create gas snapshot
	@echo "$(BLUE)📸 Creating gas snapshot...$(NC)"
	@$(FORGE) snapshot
	@echo "$(GREEN)✅ Snapshot saved to .gas-snapshot$(NC)"

##@ Quick Commands

quick-test: build test ## Quick: build and test

quick-app: build test-app ## Quick: build and test AppContract

quick-integration: build test-integration ## Quick: build and test integration

##@ CI/CD

ci-test: ## Run tests in CI mode (more fuzz runs)
	@echo "$(BLUE)🤖 Running CI tests...$(NC)"
	@FOUNDRY_PROFILE=ci $(FORGE) test -vv

ci-coverage: ## Generate coverage for CI
	@echo "$(BLUE)🤖 Running CI coverage...$(NC)"
	@$(FORGE) coverage --report summary

##@ Information

diagnose: ## Diagnose Foundry installation
	@echo "$(BLUE)🔍 Foundry Installation Diagnostics$(NC)"
	@echo ""
	@echo "1. Checking PATH for forge:"
	@if command -v forge &> /dev/null; then \
		echo "   $(GREEN)✅ Found in PATH: $$(command -v forge)$(NC)"; \
		forge --version | head -n 1; \
	else \
		echo "   $(YELLOW)⚠️  Not found in PATH$(NC)"; \
	fi
	@echo ""
	@echo "2. Checking ~/.foundry/bin/forge:"
	@if [ -f "$(HOME)/.foundry/bin/forge" ]; then \
		echo "   $(GREEN)✅ Found: $(HOME)/.foundry/bin/forge$(NC)"; \
		$(HOME)/.foundry/bin/forge --version | head -n 1; \
	else \
		echo "   $(RED)❌ Not found$(NC)"; \
	fi
	@echo ""
	@echo "3. Makefile will use:"
	@echo "   FORGE = $(FORGE)"
	@if $(FORGE) --version &> /dev/null; then \
		echo "   $(GREEN)✅ This command works!$(NC)"; \
	else \
		echo "   $(RED)❌ This command does not work$(NC)"; \
		echo "   $(YELLOW)💡 Run: make install$(NC)"; \
	fi
	@echo ""
	@echo "4. Project dependencies:"
	@if [ -d "lib/forge-std" ]; then \
		echo "   $(GREEN)✅ forge-std installed$(NC)"; \
	else \
		echo "   $(YELLOW)⚠️  forge-std not installed$(NC)"; \
		echo "   $(YELLOW)💡 Run: make install$(NC)"; \
	fi

show-config: ## Show Foundry configuration
	@echo "$(BLUE)⚙️  Foundry Configuration:$(NC)"
	@$(FORGE) config

list-tests: ## List all test functions
	@echo "$(BLUE)📋 Available tests:$(NC)"
	@grep -r "function test" test/ --include="*.sol" | \
		sed 's/.*function /  • /' | \
		sed 's/(.*$$//' | \
		sort

size: ## Show contract sizes
	@echo "$(BLUE)📏 Contract sizes:$(NC)"
	@$(FORGE) build --sizes

##@ Utilities

watch: ## Watch for changes and run tests
	@echo "$(BLUE)👀 Watching for changes...$(NC)"
	@while true; do \
		inotifywait -r -e modify test/ *.sol 2>/dev/null && \
		clear && \
		make test || true; \
	done

tree: ## Show contract dependency tree
	@echo "$(BLUE)🌳 Contract dependency tree:$(NC)"
	@$(FORGE) tree

##@ Development Workflows

# Complete workflow: clean, install, build, test
all: clean install build test ## Run complete workflow

# Pre-commit checks
pre-commit: fmt build test ## Run pre-commit checks

# Quick iteration workflow
dev: ## Development mode: format, build, test
	@make fmt
	@make build
	@make test

# Release preparation
prepare-release: clean install build test-all test-gas test-coverage ## Prepare for release

##@ Project Info

info: ## Display project information
	@echo "$(BLUE)╔════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║    Diox Contracts - Ethereum Sample           ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Compiler:$(NC)    Solidity 0.8.0"
	@echo "$(GREEN)Framework:$(NC)   Foundry"
	@echo "$(GREEN)Tests:$(NC)       $$(find test -name "*.t.sol" | wc -l) test files"
	@echo "$(GREEN)Contracts:$(NC)   $$(find . -maxdepth 1 -name "*.sol" -not -path "*/test/*" | wc -l) contracts"
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "  1. make install    # Install dependencies"
	@echo "  2. make build      # Compile contracts"
	@echo "  3. make test       # Run tests"
	@echo ""
	@echo "$(YELLOW)Common Commands:$(NC)"
	@echo "  make test-app      # Test AppContract"
	@echo "  make test-gas      # Gas report"
	@echo "  make test-coverage # Coverage report"
	@echo ""

