#!/bin/bash

# Bundle Size Check Script for CI/CD
# Analyzes WASM output sizes and compares against baseline
# Fails if bundle size increases by >5% compared to main branch

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
THRESHOLD="${BUNDLE_SIZE_THRESHOLD:-5.0}"
BASELINE_FILE="${BUNDLE_SIZE_BASELINE:-.bundle-size-baseline.json}"
OUTPUT_FILE="${BUNDLE_SIZE_REPORT:-bundle-size-report.json}"
WASM_TARGET="target/wasm32-unknown-unknown/release"

# Functions
print_header() {
    echo ""
    echo "=== Bundle Size Monitor ==="
    echo "$1"
    echo ""
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    -echo "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Determine if we should create a baseline or check
MODE="${BUNDLE_SIZE_MODE:-check}"

if [[ "$MODE" == "baseline" ]]; then
    print_header "Creating Baseline"

    # Build WASM packages first
    print_info "Building WASM packages..."
    cargo build --target wasm32-unknown-unknown --release --workspace

    # Create baseline
    cargo run --bin bundle-size-monitor -- baseline "$BASELINE_FILE"
    exit $?
fi

# Check mode
print_header "Checking Bundle Sizes"
print_info "Threshold: ${THRESHOLD}%"
print_info "Baseline: $BASELINE_FILE"
print_info "Output: $OUTPUT_FILE"
echo ""

# Build WASM packages first
print_info "Building WASM packages..."
cargo build --target wasm32-unknown-unknown --release --workspace

# Check if WASM files exist
if ! compgen -G "$WASM_TARGET/*.wasm" > /dev/null; then
    print_error "No WASM files found in $WASM_TARGET"
    exit 1
fi

# Download baseline from main branch if it doesn't exist
if [[ ! -f "$BASELINE_FILE" ]]; then
    print_info "Baseline file not found locally. Fetching from main branch..."

    # Determine git remote URL
    REMOTE_URL=$(git config --get remote.origin.url)
    REPO_SLUG=$(echo "$REMOTE_URL" | sed -E 's|.*[:/]([^/]+/[^/]+)\.git|\1|')

    if [[ -n "$GITHUB_REPOSITORY" ]]; then
        REPO_SLUG="$GITHUB_REPOSITORY"
    fi

    if [[ -n "$REPO_SLUG" ]]; then
        # Try downloading from GitHub
        MAIN_BRANCH_URL="https://raw.githubusercontent.com/$REPO_SLUG/main/.bundle-size-baseline.json"

        if curl --fail --silent --output "$BASELINE_FILE" "$MAIN_BRANCH_URL"; then
            print_success "Downloaded baseline from main branch"
        else
            print_warning "Could not download baseline from main branch"
            print_info "Creating baseline from current build..."
            cargo run --bin bundle-size-monitor -- baseline "$BASELINE_FILE"
        fi
    else
        print_warning "Cannot determine repository URL. Creating baseline from current build..."
        cargo run --bin bundle-size-monitor -- baseline "$BASELINE_FILE"
    fi
fi

# Run the bundle size monitor
print_info "Running bundle size analysis..."

# Build and run the monitor
cargo build --bin bundle-size-monitor

if cargo run --bin bundle-size-monitor -- check "$THRESHOLD" "$BASELINE_FILE" "$OUTPUT_FILE"; then
    print_success "Bundle size check passed!"

    # Generate summary
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo ""
        echo "--- Summary ---"
        echo "Total size: $(jq -r '.summary.total_size' "$OUTPUT_FILE" | numfmt --to=iec-i --suffix=B)"
        echo "Baseline: $(jq -r '.summary.baseline_total' "$OUTPUT_FILE" | numfmt --to=iec-i --suffix=B)"
        echo "Delta: $(jq -r '.summary.total_delta_percent' "$OUTPUT_FILE")%"
        echo "Status: PASS"
    fi

    exit 0
else
    EXIT_CODE=$?

    print_error "Bundle size check failed!"

    if [[ -f "$OUTPUT_FILE" ]]; then
        echo ""
        echo "--- Summary ---"
        TOTAL_SIZE=$(jq -r '.summary.total_size' "$OUTPUT_FILE")
        BASELINE_TOTAL=$(jq -r '.summary.baseline_total' "$OUTPUT_FILE")
        DELTA_PERCENT=$(jq -r '.summary.total_delta_percent' "$OUTPUT_FILE")

        echo "Total size: $(echo "$TOTAL_SIZE" | numfmt --to=iec-i --suffix=B 2>/dev/null || echo "$TOTAL_SIZE")"
        echo "Baseline: $(echo "$BASELINE_TOTAL" | numfmt --to=iec-i --suffix=B 2>/dev/null || echo "$BASELINE_TOTAL")"
        echo "Delta: ${DELTA_PERCENT}% (threshold: ${THRESHOLD}%)"
        echo "Status: FAIL"
        echo ""
        echo "--- Bundle Changes ---"
        echo "Bundle | Baseline | Current | Delta | Change | Status"
        "-------|----------|---------|-------|--------|-------"
        jq -r '.comparisons[] | [
            .name,
            (.baseline_size | tostring),
            (.current_size | tostring),
            (.delta_bytes | tostring),
            (.delta_percent | tostring + "%"),
            .status
        ] | join(" | ")' "$OUTPUT_FILE"
    fi

    exit $EXIT_CODE
fi
