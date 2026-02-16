#!/usr/bin/env bash
# =============================================================================
# Automated Test Coverage Report Generator for Leptos ShadCN UI
# =============================================================================
# This script generates comprehensive test coverage reports using cargo-llvm-cov
# and supports multiple output formats (HTML, JSON, LCov, terminal).
#
# Usage:
#   ./scripts/generate_coverage_report.sh [OPTIONS]
#
# Options:
#   --workspace          Generate coverage for entire workspace (default)
#   --package <name>     Generate coverage for specific package
#   --format <fmt>       Output format: html, json, lcov, terminal, all (default: all)
#   --output-dir <dir>   Custom output directory (default: coverage-reports/)
#   --open               Open HTML report in browser after generation
#   --fail-under <pct>   Fail if coverage below percentage (default: 95)
#   --verbose            Enable verbose output
#   --ci                 CI mode (optimized for CI/CD pipelines)
#   --help               Show this help message
#
# Examples:
#   ./scripts/generate_coverage_report.sh
#   ./scripts/generate_coverage_report.sh --package leptos-shadcn-button
#   ./scripts/generate_coverage_report.sh --format html --open
#   ./scripts/generate_coverage_report.sh --ci --fail-under 90
#
# =============================================================================

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default values
WORKSPACE_FLAG="--workspace"
PACKAGE_FLAG=""
OUTPUT_FORMATS="all"
OUTPUT_DIR="${PROJECT_ROOT}/coverage-reports"
OPEN_REPORT=false
FAIL_UNDER=95
VERBOSE=false
CI_MODE=false
COVERAGE_DIR="${PROJECT_ROOT}/target/coverage"

# Colors for terminal output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# =============================================================================
# Helper Functions
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_verbose() {
    if [[ "${VERBOSE}" == true ]]; then
        echo -e "${PURPLE}[VERBOSE]${NC} $*"
    fi
}

print_header() {
    echo ""
    echo -e "${CYAN}=============================================================================${NC}"
    echo -e "${CYAN}$*${NC}"
    echo -e "${CYAN}=============================================================================${NC}"
    echo ""
}

show_help() {
    cat << EOF
${CYAN}Automated Test Coverage Report Generator${NC}

${GREEN}Usage:${NC}
    $0 [OPTIONS]

${GREEN}Options:${NC}
    --workspace          Generate coverage for entire workspace (default)
    --package <name>     Generate coverage for specific package
    --format <fmt>       Output format: html, json, lcov, terminal, all (default: all)
    --output-dir <dir>   Custom output directory (default: coverage-reports/)
    --open               Open HTML report in browser after generation
    --fail-under <pct>   Fail if coverage below percentage (default: 95)
    --verbose            Enable verbose output
    --ci                 CI mode (optimized for CI/CD pipelines)
    --help               Show this help message

${GREEN}Examples:${NC}
    $0
    $0 --package leptos-shadcn-button
    $0 --format html --open
    $0 --ci --fail-under 90

${GREEN}Environment Variables:${NC}
    COVERAGE_DIR          Coverage data directory (default: target/coverage)
    COVERAGE_OUTPUT_DIR   Report output directory (default: coverage-reports)
    COVERAGE_MINIMUM_*    Minimum coverage thresholds

EOF
}

# =============================================================================
# Argument Parsing
# =============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --workspace)
                WORKSPACE_FLAG="--workspace"
                shift
                ;;
            --package)
                PACKAGE_FLAG="-p $2"
                shift 2
                ;;
            --format)
                OUTPUT_FORMATS="$2"
                shift 2
                ;;
            --output-dir)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --open)
                OPEN_REPORT=true
                shift
                ;;
            --fail-under)
                FAIL_UNDER="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --ci)
                CI_MODE=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# Dependency Checking
# =============================================================================

check_dependencies() {
    print_header "Checking Dependencies"

    local missing_deps=()

    # Check for cargo
    if ! command -v cargo &> /dev/null; then
        missing_deps+=("cargo")
    fi

    # Check for cargo-llvm-cov
    if ! cargo llvm-cov --version &> /dev/null; then
        missing_deps+=("cargo-llvm-cov")
    fi

    # Check for grcov (optional, for alternative coverage)
    if ! command -v grcov &> /dev/null; then
        log_verbose "grcov not found (optional, for alternative coverage reports)"
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        log_info "Install missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case $dep in
                cargo-llvm-cov)
                    echo "  cargo install cargo-llvm-cov"
                    ;;
                *)
                    echo "  Please install: $dep"
                    ;;
            esac
        done
        exit 1
    fi

    log_success "All dependencies satisfied"
}

# =============================================================================
# Coverage Report Generation
# =============================================================================

setup_coverage_environment() {
    print_header "Setting Up Coverage Environment"

    # Create output directory
    mkdir -p "${OUTPUT_DIR}"
    mkdir -p "${COVERAGE_DIR}"

    # Set environment variables for coverage
    export CARGO_INCREMENTAL=0
    export LLVM_PROFILE_FILE="${COVERAGE_DIR}/%p-%m.profraw"

    log_verbose "Coverage directory: ${COVERAGE_DIR}"
    log_verbose "Output directory: ${OUTPUT_DIR}"
    log_verbose "Fail under threshold: ${FAIL_UNDER}%"

    log_success "Coverage environment configured"
}

clean_coverage_data() {
    log_info "Cleaning previous coverage data..."
    rm -rf "${COVERAGE_DIR}"/*.profraw
    rm -rf "${PROJECT_ROOT}/target/coverage"/*.profdata
    log_success "Coverage data cleaned"
}

generate_coverage_reports() {
    print_header "Generating Coverage Reports"

    local cargo_flags=""
    local coverage_flags=""

    # Build cargo flags
    if [[ -n "${WORKSPACE_FLAG}" ]]; then
        cargo_flags="${WORKSPACE_FLAG}"
    fi
    if [[ -n "${PACKAGE_FLAG}" ]]; then
        cargo_flags="${cargo_flags} ${PACKAGE_FLAG}"
    fi

    # CI mode optimizations
    if [[ "${CI_MODE}" == true ]]; then
        coverage_flags="--no-fail-fast"
    fi

    log_info "Running tests with coverage instrumentation..."
    log_verbose "Cargo flags: ${cargo_flags}"

    # Generate coverage based on format
    case "${OUTPUT_FORMATS}" in
        html)
            log_info "Generating HTML coverage report..."
            cargo llvm-cov ${cargo_flags} ${coverage_flags} \
                --html \
                --output-dir "${OUTPUT_DIR}/html" \
                --fail-under "${FAIL_UNDER}"
            ;;
        json)
            log_info "Generating JSON coverage report..."
            cargo llvm-cov ${cargo_flags} ${coverage_flags} \
                --json \
                --output-path "${OUTPUT_DIR}/coverage.json" \
                --fail-under "${FAIL_UNDER}"
            ;;
        lcov)
            log_info "Generating LCov coverage report..."
            cargo llvm-cov ${cargo_flags} ${coverage_flags} \
                --lcov \
                --output-path "${OUTPUT_DIR}/coverage.lcov" \
                --fail-under "${FAIL_UNDER}"
            ;;
        terminal)
            log_info "Generating terminal coverage report..."
            cargo llvm-cov ${cargo_flags} ${coverage_flags} \
                --text \
                --fail-under "${FAIL_UNDER}"
            ;;
        all)
            log_info "Generating all coverage report formats..."
            cargo llvm-cov ${cargo_flags} ${coverage_flags} \
                --html \
                --output-dir "${OUTPUT_DIR}/html" \
                --json \
                --output-path "${OUTPUT_DIR}/coverage.json" \
                --lcov \
                --output-path "${OUTPUT_DIR}/coverage.lcov" \
                --text \
                --fail-under "${FAIL_UNDER}"
            ;;
        *)
            log_error "Unknown output format: ${OUTPUT_FORMATS}"
            exit 1
            ;;
    esac

    log_success "Coverage reports generated"
}

generate_summary_report() {
    print_header "Coverage Summary Report"

    local summary_file="${OUTPUT_DIR}/summary.txt"

    # Extract coverage information from JSON report
    if [[ -f "${OUTPUT_DIR}/coverage.json" ]]; then
        log_info "Generating coverage summary..."

        # Parse JSON and create human-readable summary
        cat > "${summary_file}" << EOF
Leptos ShadCN UI - Test Coverage Summary
==========================================
Generated: $(date)

Coverage Threshold: ${FAIL_UNDER}%

EOF

        # Add coverage statistics if available
        if command -v jq &> /dev/null; then
            jq -r '"Overall Coverage: " + (.coverage | tostring) + "%"' \
                "${OUTPUT_DIR}/coverage.json" 2>/dev/null >> "${summary_file}" || true
        fi

        log_success "Summary report generated: ${summary_file}"
    fi

    # Display terminal summary
    if [[ "${OUTPUT_FORMATS}" != "terminal" ]] && [[ "${OUTPUT_FORMATS}" != "all" ]]; then
        log_info "Generating terminal summary..."
        cargo llvm-cov ${WORKSPACE_FLAG} ${PACKAGE_FLAG} --text 2>&1 | head -50
    fi
}

generate_coverage_badge() {
    log_info "Generating coverage badge..."

    local badge_dir="${OUTPUT_DIR}/badges"
    mkdir -p "${badge_dir}"

    # Extract coverage percentage
    local coverage_pct=""
    if [[ -f "${OUTPUT_DIR}/coverage.json" ]] && command -v jq &> /dev/null; then
        coverage_pct=$(jq -r '.coverage // "unknown"' "${OUTPUT_DIR}/coverage.json" 2>/dev/null || echo "unknown")
    else
        # Fallback: extract from terminal output
        coverage_pct=$(cargo llvm-cov ${WORKSPACE_FLAG} ${PACKAGE_FLAG} --text 2>/dev/null | grep -oP '\d+\.\d+%' | head -1 || echo "unknown")
    fi

    if [[ "${coverage_pct}" != "unknown" ]]; then
        # Generate SVG badge
        local color="red"
        local pct_num=$(echo "${coverage_pct}" | sed 's/%//')
        if (( $(echo "${pct_num} >= 95" | bc -l) )); then
            color="brightgreen"
        elif (( $(echo "${pct_num} >= 90" | bc -l) )); then
            color="green"
        elif (( $(echo "${pct_num} >= 80" | bc -l) )); then
            color="yellow"
        elif (( $(echo "${pct_num} >= 70" | bc -l) )); then
            color="orange"
        fi

        cat > "${badge_dir}/coverage.svg" << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="120" height="20">
  <linearGradient id="b" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <mask id="a">
    <rect width="120" height="20" rx="3" fill="#fff"/>
  </mask>
  <g mask="url(#a)">
    <path fill="#555" d="M0 0h60v20H0z"/>
    <path fill="${color}" d="M60 0h60v20H60z"/>
    <path fill="url(#b)" d="M0 0h120v20H0z"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
    <text x="30" y="15" fill="#010101" fill-opacity=".3">coverage</text>
    <text x="30" y="14">coverage</text>
    <text x="90" y="15" fill="#010101" fill-opacity=".3">${coverage_pct}</text>
    <text x="90" y="14">${coverage_pct}</text>
  </g>
</svg>
EOF
        log_success "Coverage badge generated: ${badge_dir}/coverage.svg"
    else
        log_warning "Could not generate coverage badge"
    fi
}

open_html_report() {
    if [[ "${OPEN_REPORT}" == true ]] && [[ -d "${OUTPUT_DIR}/html" ]]; then
        log_info "Opening HTML coverage report..."
        local index_file="${OUTPUT_DIR}/html/index.html"

        if [[ -f "${index_file}" ]]; then
            # Open in default browser (cross-platform)
            if command -v xdg-open &> /dev/null; then
                xdg-open "${index_file}"
            elif command -v open &> /dev/null; then
                open "${index_file}"
            elif command -v start &> /dev/null; then
                start "${index_file}"
            else
                log_warning "Could not open browser. Please open ${index_file} manually."
            fi
        else
            log_warning "HTML report not found at ${index_file}"
        fi
    fi
}

generate_ci_report() {
    if [[ "${CI_MODE}" == true ]]; then
        print_header "CI/CD Report Generation"

        local ci_report_file="${OUTPUT_DIR}/ci-report.json"

        log_info "Generating CI/CD optimized report..."

        # Create CI-friendly JSON report
        if [[ -f "${OUTPUT_DIR}/coverage.json" ]]; then
            cp "${OUTPUT_DIR}/coverage.json" "${ci_report_file}"

            # Add CI metadata
            if command -v jq &> /dev/null; then
                jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                   --arg branch "${GIT_BRANCH:-unknown}" \
                   --arg commit "${GIT_COMMIT:-unknown}" \
                   '. + {
                       timestamp: $timestamp,
                       branch: $branch,
                       commit: $commit,
                       project: "leptos-shadcn-ui"
                   }' "${ci_report_file}" > "${ci_report_file}.tmp"
                mv "${ci_report_file}.tmp" "${ci_report_file}"
            fi

            log_success "CI report generated: ${ci_report_file}"
        fi
    fi
}

display_final_summary() {
    print_header "Coverage Report Generation Complete"

    echo -e "${GREEN}Output Directory:${NC} ${OUTPUT_DIR}"
    echo ""

    if [[ "${OUTPUT_FORMATS}" == "all" ]] || [[ "${OUTPUT_FORMATS}" == "html" ]]; then
        if [[ -d "${OUTPUT_DIR}/html" ]]; then
            echo -e "${GREEN}HTML Report:${NC}     ${OUTPUT_DIR}/html/index.html"
        fi
    fi

    if [[ "${OUTPUT_FORMATS}" == "all" ]] || [[ "${OUTPUT_FORMATS}" == "json" ]]; then
        if [[ -f "${OUTPUT_DIR}/coverage.json" ]]; then
            echo -e "${GREEN}JSON Report:${NC}     ${OUTPUT_DIR}/coverage.json"
        fi
    fi

    if [[ "${OUTPUT_FORMATS}" == "all" ]] || [[ "${OUTPUT_FORMATS}" == "lcov" ]]; then
        if [[ -f "${OUTPUT_DIR}/coverage.lcov" ]]; then
            echo -e "${GREEN}LCov Report:${NC}     ${OUTPUT_DIR}/coverage.lcov"
        fi
    fi

    if [[ -f "${OUTPUT_DIR}/summary.txt" ]]; then
        echo -e "${GREEN}Summary:${NC}        ${OUTPUT_DIR}/summary.txt"
    fi

    if [[ -f "${OUTPUT_DIR}/badges/coverage.svg" ]]; then
        echo -e "${GREEN}Badge:${NC}          ${OUTPUT_DIR}/badges/coverage.svg"
    fi

    echo ""
    log_success "Coverage report generation completed successfully!"
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    parse_arguments "$@"
    check_dependencies
    setup_coverage_environment
    clean_coverage_data
    generate_coverage_reports
    generate_summary_report
    generate_coverage_badge
    generate_ci_report
    open_html_report
    display_final_summary
}

# Run main function
main "$@"
