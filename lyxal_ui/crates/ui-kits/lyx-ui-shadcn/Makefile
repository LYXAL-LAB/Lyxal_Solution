.PHONY: help dev build test test-rust test-e2e clean install-deps setup-playwright lint fmt check docs

# Default target
help: ## Show this help message
	@echo "shadcn/ui Rust Development Commands"
	@echo "=================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development
dev: ## Start development environment with file watching
	@echo "🚀 Starting development environment..."
	cargo watch -x "check --workspace" -x "test --workspace --lib"

dev-examples: ## Run example applications
	@echo "🌟 Starting Leptos examples..."
	cd book-examples/leptos && trunk serve --open

# Building
build: ## Build all packages and examples
	@echo "🔨 Building all packages..."
	cargo build --workspace
	cargo build --workspace --target wasm32-unknown-unknown

build-release: ## Build optimized release versions
	@echo "🏗️ Building release versions..."
	cargo build --workspace --release
	cargo build --workspace --release --target wasm32-unknown-unknown

build-examples: ## Build example applications
	@echo "📦 Building examples..."
	cd book-examples/leptos && trunk build --release
	cd book-examples/yew && trunk build --release

# Testing
test: test-rust test-e2e ## Run all tests (Rust + E2E)

test-rust: ## Run Rust unit and integration tests
	@echo "🧪 Running Rust tests..."
	cargo test --workspace --lib
	cargo test --workspace --target wasm32-unknown-unknown

test-rust-verbose: ## Run Rust tests with verbose output
	@echo "🔍 Running Rust tests (verbose)..."
	RUST_LOG=debug cargo test --workspace --lib -- --nocapture

test-single: ## Run tests for a specific component (usage: make test-single COMPONENT=button)
	@if [ -z "$(COMPONENT)" ]; then \
		echo "❌ Please specify COMPONENT. Usage: make test-single COMPONENT=button"; \
		exit 1; \
	fi
	@echo "🎯 Testing $(COMPONENT) component..."
	cargo test -p shadcn-ui-leptos-$(COMPONENT)
	cargo test -p shadcn-ui-yew-$(COMPONENT)

test-e2e: install-playwright ## Run Playwright E2E tests
	@echo "🎭 Running Playwright E2E tests..."
	pnpm playwright test

test-e2e-headed: ## Run Playwright tests in headed mode
	@echo "🎭 Running Playwright E2E tests (headed)..."
	pnpm playwright test --headed

test-e2e-ui: ## Run Playwright E2E tests with UI
	@echo "🎭 Running Playwright E2E tests with UI..."
	pnpm playwright test --ui

test-e2e-debug: ## Run Playwright E2E tests in debug mode
	@echo "🐛 Running Playwright E2E tests in debug mode..."
	pnpm playwright test --debug

test-e2e-specific: ## Run specific E2E test file (usage: make test-e2e-specific FILE=filename)
	@echo "🎯 Running specific E2E test: $(FILE)..."
	pnpm playwright test $(FILE)

test-e2e-browser: ## Run E2E tests in specific browser (usage: make test-e2e-browser BROWSER=chromium)
	@echo "🌐 Running E2E tests in $(BROWSER)..."
	pnpm playwright test --project=$(BROWSER)

test-e2e-parallel: ## Run E2E tests in parallel
	@echo "⚡ Running E2E tests in parallel..."
	pnpm playwright test --workers=4

test-e2e-report: ## Generate E2E test report
	@echo "📊 Generating E2E test report..."
	pnpm playwright show-report

test-e2e-install: ## Install Playwright browsers
	@echo "📦 Installing Playwright browsers..."
	pnpm playwright install

test-e2e-codegen: ## Generate E2E test code
	@echo "🔄 Generating E2E test code..."
	pnpm playwright codegen http://127.0.0.1:8080

# WASM Testing
test-wasm: ## Run comprehensive WASM browser tests
	@echo "🧪 Running WASM browser tests..."
	./scripts/run-wasm-tests.sh

test-wasm-browsers: ## Run WASM tests on specific browsers (usage: make test-wasm-browsers BROWSERS=chromium,firefox)
	@if [ -z "$(BROWSERS)" ]; then \
		echo "❌ Please specify BROWSERS. Usage: make test-wasm-browsers BROWSERS=chromium,firefox"; \
		exit 1; \
	fi
	@echo "🧪 Running WASM tests on $(BROWSERS)..."
	./scripts/run-wasm-tests.sh -b "$(BROWSERS)"

test-wasm-headed: ## Run WASM tests in headed mode
	@echo "🧪 Running WASM tests in headed mode..."
	./scripts/run-wasm-tests.sh -H

test-wasm-parallel: ## Run WASM tests in parallel
	@echo "🧪 Running WASM tests in parallel..."
	./scripts/run-wasm-tests.sh -p

test-wasm-verbose: ## Run WASM tests with verbose output
	@echo "🧪 Running WASM tests with verbose output..."
	./scripts/run-wasm-tests.sh -v

# Enhanced E2E Testing
test-e2e-enhanced: ## Run enhanced E2E tests with comprehensive reporting
	@echo "🎭 Running enhanced E2E tests..."
	pnpm playwright test --config=playwright.config.ts

test-e2e-ci: ## Run E2E tests in CI mode
	@echo "🚀 Running E2E tests in CI mode..."
	CI=true pnpm playwright test --config=playwright.config.ts

test-e2e-debug: ## Run E2E tests in debug mode
	@echo "🐛 Running E2E tests in debug mode..."
	DEBUG=true HEADLESS=false pnpm playwright test --config=playwright.config.ts

test-e2e-performance: ## Run E2E performance tests only
	@echo "📈 Running E2E performance tests..."
	pnpm playwright test --project=performance-tests

test-e2e-accessibility: ## Run E2E accessibility tests only
	@echo "♿ Running E2E accessibility tests..."
	pnpm playwright test --project=accessibility-tests

test-e2e-wasm: ## Run E2E WASM tests only
	@echo "🧪 Running E2E WASM tests..."
	pnpm playwright test --project=wasm-tests

test-e2e-report: ## Generate comprehensive E2E test report
	@echo "📊 Generating E2E test report..."
	pnpm playwright show-report

# Performance Benchmarking
benchmark: ## Run performance benchmarks
	@echo "🏃 Running performance benchmarks..."
	./scripts/run-performance-benchmarks.sh benchmark

benchmark-components: ## Run benchmarks for specific components (usage: make benchmark-components COMPONENTS=button,input)
	@if [ -z "$(COMPONENTS)" ]; then \
		echo "❌ Please specify COMPONENTS. Usage: make benchmark-components COMPONENTS=button,input"; \
		exit 1; \
	fi
	@echo "🏃 Running benchmarks for $(COMPONENTS)..."
	./scripts/run-performance-benchmarks.sh benchmark -c "$(COMPONENTS)"

benchmark-html: ## Run benchmarks and generate HTML report
	@echo "🏃 Running benchmarks with HTML report..."
	./scripts/run-performance-benchmarks.sh benchmark -f html -o test-results/performance/benchmark-report.html

regression-test: ## Run performance regression tests
	@echo "📊 Running performance regression tests..."
	./scripts/run-performance-benchmarks.sh regression

regression-update: ## Run regression tests and update baseline
	@echo "📊 Running regression tests with baseline update..."
	./scripts/run-performance-benchmarks.sh regression -u

performance-monitor: ## Start automated performance monitoring
	@echo "📈 Starting automated performance monitoring..."
	./scripts/run-performance-benchmarks.sh monitor

performance-monitor-alerts: ## Start monitoring with alerts enabled
	@echo "📈 Starting performance monitoring with alerts..."
	./scripts/run-performance-benchmarks.sh monitor -a

setup-baseline: ## Setup performance baseline
	@echo "🔧 Setting up performance baseline..."
	./scripts/run-performance-benchmarks.sh setup

performance-report: ## Generate performance report
	@echo "📄 Generating performance report..."
	./scripts/run-performance-benchmarks.sh report

# Accessibility Automation
accessibility-audit: ## Run comprehensive accessibility audit
	@echo "♿ Running accessibility audit..."
	./scripts/run-accessibility-audit.sh

accessibility-audit-wcag: ## Run accessibility audit with specific WCAG level (usage: make accessibility-audit-wcag LEVEL=AAA)
	@if [ -z "$(LEVEL)" ]; then \
		echo "❌ Please specify LEVEL. Usage: make accessibility-audit-wcag LEVEL=AAA"; \
		exit 1; \
	fi
	@echo "♿ Running accessibility audit with WCAG $(LEVEL)..."
	./scripts/run-accessibility-audit.sh -l "$(LEVEL)"

accessibility-audit-components: ## Run accessibility audit for specific components (usage: make accessibility-audit-components COMPONENTS=button,input)
	@if [ -z "$(COMPONENTS)" ]; then \
		echo "❌ Please specify COMPONENTS. Usage: make accessibility-audit-components COMPONENTS=button,input"; \
		exit 1; \
	fi
	@echo "♿ Running accessibility audit for $(COMPONENTS)..."
	./scripts/run-accessibility-audit.sh -c "$(COMPONENTS)"

accessibility-audit-html: ## Run accessibility audit and generate HTML report
	@echo "♿ Running accessibility audit with HTML report..."
	./scripts/run-accessibility-audit.sh -f html -o test-results/accessibility/accessibility-report.html

accessibility-audit-verbose: ## Run accessibility audit with verbose output
	@echo "♿ Running accessibility audit with verbose output..."
	./scripts/run-accessibility-audit.sh -v

accessibility-audit-focus: ## Run accessibility audit focusing on focus management
	@echo "♿ Running accessibility audit focusing on focus management..."
	./scripts/run-accessibility-audit.sh --no-color-contrast --no-screen-reader

# Test Coverage Reporting
coverage: ## Generate comprehensive coverage reports (HTML, JSON, LCov)
	@echo "📊 Generating coverage reports..."
	./scripts/generate_coverage_report.sh --format all

coverage-html: ## Generate HTML coverage report
	@echo "📊 Generating HTML coverage report..."
	./scripts/generate_coverage_report.sh --format html --open

coverage-json: ## Generate JSON coverage report
	@echo "📊 Generating JSON coverage report..."
	./scripts/generate_coverage_report.sh --format json

coverage-lcov: ## Generate LCov coverage report
	@echo "📊 Generating LCov coverage report..."
	./scripts/generate_coverage_report.sh --format lcov

coverage-terminal: ## Generate terminal coverage report
	@echo "📊 Generating terminal coverage report..."
	./scripts/generate_coverage_report.sh --format terminal

coverage-component: ## Generate coverage for specific component (usage: make coverage-component COMPONENT=button)
	@if [ -z "$(COMPONENT)" ]; then \
		echo "❌ Please specify COMPONENT. Usage: make coverage-component COMPONENT=button"; \
		exit 1; \
	fi
	@echo "📊 Generating coverage for $(COMPONENT)..."
	./scripts/generate_coverage_report.sh --package leptos-shadcn-$(COMPONENT)

coverage-open: ## Open HTML coverage report in browser
	@echo "📊 Opening coverage report..."
	./scripts/generate_coverage_report.sh --format html --open

coverage-ci: ## Generate coverage reports in CI mode
	@echo "📊 Generating coverage reports (CI mode)..."
	./scripts/generate_coverage_report.sh --ci --fail-under 95

coverage-verify: ## Verify coverage meets minimum thresholds
	@echo "📊 Verifying coverage thresholds..."
	./scripts/generate_coverage_report.sh --fail-under 95 --ci

coverage-badge: ## Generate coverage badge
	@echo "📊 Generating coverage badge..."
	python3 scripts/coverage_reporter.py --format json --output-dir coverage-reports/badges

coverage-trend: ## Analyze coverage trends over time
	@echo "📊 Analyzing coverage trends..."
	python3 scripts/coverage_reporter.py --trend --format terminal

coverage-full: coverage coverage-badge coverage-trend ## Generate all coverage reports and badges
	@echo "✅ Full coverage report generation complete!"

# Production Readiness
analyze-bundle: ## Analyze bundle sizes and optimization opportunities
	@echo "📦 Analyzing bundle sizes for production readiness..."
	./scripts/analyze_bundle.sh

build-production: ## Build production-optimized version
	@echo "🏗️ Building production-optimized version..."
	./scripts/build_production.sh

# WASM Size Optimization
build-wasm-optimized: ## Build WASM with size optimizations (<2MB target)
	@echo "🚀 Building WASM with size optimizations..."
	./scripts/build-wasm-optimized.sh

build-wasm-release: ## Build WASM release with maximum size optimizations
	@echo "🏗️ Building WASM release (maximum optimization)..."
	cargo build --profile wasm-release --target wasm32-unknown-unknown -p leptos-shadcn-ui-wasm

check-wasm-size: ## Check WASM bundle size without building
	@echo "📊 Checking WASM bundle sizes..."
	@find . -name "*.wasm" -type f -exec sh -c 'echo "$$(stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null) bytes - $$1"' _ {} \; 2>/dev/null | sort -n | tail -10

measure-wasm: ## Measure and report WASM bundle size
	@echo "📏 Measuring WASM bundle size..."
	@if [ -f "target/wasm32-unknown-unknown/release/leptos_shadcn_ui_wasm.wasm" ]; then \
		SIZE=$$(stat -c%s "target/wasm32-unknown-unknown/release/leptos_shadcn_ui_wasm.wasm" 2>/dev/null || stat -f%z "target/wasm32-unknown-unknown/release/leptos_shadcn_ui_wasm.wasm"); \
		echo "Size: $$SIZE bytes ($$(awk "BEGIN {printf \"%.2f\", $$size/1048576}") MB)"; \
		if [ $$SIZE -le 2097152 ]; then \
			echo "✅ SUCCESS: Under 2MB target"; \
		else \
			echo "❌ FAILED: Exceeds 2MB target"; \
		fi \
	else \
		echo "No WASM file found. Run 'make build-wasm-optimized' first."; \
	fi

optimize-wasm: build-wasm-optimized check-wasm-size ## Build optimized WASM and check size

production-check: analyze-bundle build-production ## Complete production readiness check
	@echo "✅ Production readiness check complete!"

# Quality & Linting
check: ## Run cargo check on all packages
	@echo "✅ Checking all packages..."
	cargo check --workspace
	cargo check --workspace --target wasm32-unknown-unknown

lint: ## Run clippy linting
	@echo "📎 Running clippy..."
	cargo clippy --workspace -- -D warnings
	cargo clippy --workspace --target wasm32-unknown-unknown -- -D warnings

fmt: ## Format code with rustfmt
	@echo "🎨 Formatting code..."
	cargo fmt --all

fmt-check: ## Check if code is formatted
	@echo "🔍 Checking code formatting..."
	cargo fmt --all -- --check

audit: ## Run security audit
	@echo "🔒 Running security audit..."
	cargo audit

# Dependencies
install-deps: ## Install all dependencies
	@echo "📦 Installing dependencies..."
	pnpm install

install-playwright: ## Install Playwright and browsers
	@echo "🎭 Installing Playwright..."
	pnpm create playwright@latest --yes
	pnpm playwright install

setup-playwright: install-deps install-playwright ## Complete Playwright setup
	@echo "✅ Playwright setup complete!"

# Documentation
docs: ## Generate and open documentation
	@echo "📚 Generating documentation..."
	cargo doc --workspace --open

docs-book: ## Build and serve the documentation book
	@echo "📖 Building documentation book..."
	cd book && mdbook serve --open

# Maintenance
clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	cargo clean
	rm -rf book-examples/*/dist
	rm -rf node_modules
	rm -rf .playwright-browsers

clean-cache: ## Clean cargo cache and lock files
	@echo "🗑️ Cleaning caches..."
	cargo clean
	rm -f Cargo.lock
	rm -f package-lock.json

update-deps: ## Update all dependencies
	@echo "⬆️ Updating dependencies..."
	cargo update
	pnpm update

# Component Generation
generate-component: ## Generate a new component (usage: make generate-component NAME=my-component FRAMEWORK=leptos)
	@if [ -z "$(NAME)" ] || [ -z "$(FRAMEWORK)" ]; then \
		echo "❌ Please specify NAME and FRAMEWORK. Usage: make generate-component NAME=my-component FRAMEWORK=leptos"; \
		exit 1; \
	fi
	@echo "🏗️ Generating $(NAME) component for $(FRAMEWORK)..."
	cargo run --bin component-generator -- --name $(NAME) --framework $(FRAMEWORK)

# Nix integration
nix-develop: ## Enter Nix development shell
	@echo "❄️ Entering Nix development shell..."
	nix develop

nix-build: ## Build using Nix
	@echo "❄️ Building with Nix..."
	nix build

# Quick fixes
fix-permissions: ## Fix file permissions
	@echo "🔧 Fixing file permissions..."
	find . -name "*.rs" -type f -exec chmod 644 {} \;
	find . -name "*.toml" -type f -exec chmod 644 {} \;
	find scripts -name "*.sh" -type f -exec chmod +x {} \;

# Git hooks
install-git-hooks: ## Install git pre-commit hooks
	@echo "🪝 Installing git hooks..."
	echo '#!/bin/sh\nmake fmt-check && make check && make test-rust' > .git/hooks/pre-commit
	chmod +x .git/hooks/pre-commit
	echo "✅ Git hooks installed!"

# Environment info
env-info: ## Show environment information
	@echo "Environment Information:"
	@echo "======================="
	@echo "Rust version: $$(rustc --version 2>/dev/null || echo 'Not installed')"
	@echo "Cargo version: $$(cargo --version 2>/dev/null || echo 'Not installed')"
	@echo "Node.js version: $$(node --version 2>/dev/null || echo 'Not installed')"
	@echo "pnpm version: $$(pnpm --version 2>/dev/null || echo 'Not installed')"
	@echo "Make version: $$(make --version 2>/dev/null | head -n1 || echo 'Not installed')"
	@echo "Git version: $$(git --version 2>/dev/null || echo 'Not installed')"
	@if command -v nix >/dev/null 2>&1; then \
		echo "Nix version: $$(nix --version 2>/dev/null)"; \
	else \
		echo "Nix version: Not installed"; \
	fi
