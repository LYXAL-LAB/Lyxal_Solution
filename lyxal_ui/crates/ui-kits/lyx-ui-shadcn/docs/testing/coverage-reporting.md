# Test Coverage Reporting Guide

This guide explains how to use and configure the automated test coverage reporting system for the Leptos ShadCN UI project.

## Overview

The coverage reporting system provides comprehensive test coverage analysis with support for multiple tools, output formats, and CI/CD integration. It helps ensure code quality and track coverage trends over time.

## Features

- **Multi-tool Support**: Works with `cargo-llvm-cov` (recommended) and `cargo-tarpaulin`
- **Multiple Output Formats**: HTML, JSON, LCov, and terminal reports
- **Coverage Thresholds**: Configurable quality gates with fail-fast support
- **Trend Analysis**: Track coverage changes across builds
- **CI/CD Integration**: GitHub Actions workflow with PR comments
- **Component-Level Coverage**: Detailed breakdown by component
- **Coverage Badges**: Auto-generated SVG badges for README/docs

## Quick Start

### Installation

First, install the coverage tool:

```bash
# Install cargo-llvm-cov (recommended)
cargo install cargo-llvm-cov

# Or install cargo-tarpaulin
cargo install cargo-tarpaulin
```

### Generate Coverage Reports

Generate all coverage report formats:

```bash
# Using the shell script
./scripts/generate_coverage_report.sh

# Using the Python script
python3 scripts/coverage_reporter.py

# Using make
make coverage
```

### View HTML Report

```bash
# Generate and open HTML report
make coverage-html

# Or using the script
./scripts/generate_coverage_report.sh --format html --open
```

## Usage

### Command-Line Options

#### Shell Script (`generate_coverage_report.sh`)

```bash
./scripts/generate_coverage_report.sh [OPTIONS]

Options:
  --workspace          Generate coverage for entire workspace (default)
  --package <name>     Generate coverage for specific package
  --format <fmt>       Output format: html, json, lcov, terminal, all (default: all)
  --output-dir <dir>   Custom output directory (default: coverage-reports/)
  --open               Open HTML report in browser after generation
  --fail-under <pct>   Fail if coverage below percentage (default: 95)
  --verbose            Enable verbose output
  --ci                 CI mode (optimized for CI/CD pipelines)
  --help               Show help message
```

Examples:

```bash
# Generate all formats
./scripts/generate_coverage_report.sh --format all

# Generate coverage for specific component
./scripts/generate_coverage_report.sh --package leptos-shadcn-button

# Generate HTML report and open in browser
./scripts/generate_coverage_report.sh --format html --open

# CI mode with custom threshold
./scripts/generate_coverage_report.sh --ci --fail-under 90
```

#### Python Script (`coverage_reporter.py`)

```bash
python3 scripts/coverage_reporter.py [OPTIONS]

Options:
  --tool <tool>           Coverage tool: llvm-cov, tarpaulin, all (default: llvm-cov)
  --format <fmt>          Output format: html, json, lcov, terminal, all (default: all)
  --output-dir <dir>      Custom output directory
  --fail-under <pct>      Fail if coverage below percentage (default: 95)
  --component <name>      Generate coverage for specific component
  --trend                 Enable trend analysis
  --ci                    CI mode
  --verbose               Enable verbose output
```

### Makefile Targets

```bash
# Generate all coverage reports
make coverage

# Generate HTML report and open
make coverage-html

# Generate JSON report
make coverage-json

# Generate LCov report
make coverage-lcov

# Generate terminal report
make coverage-terminal

# Generate coverage for specific component
make coverage-component COMPONENT=button

# Verify coverage meets thresholds
make coverage-verify

# Generate all reports including badges and trends
make coverage-full
```

## Configuration

### Coverage Thresholds

Configure coverage thresholds in `.coverage-rules.toml`:

```toml
[overall]
min_line_coverage = 95.0
min_branch_coverage = 90.0
min_function_coverage = 100.0
fail_below_threshold = true

[component_thresholds]
default_min_coverage = 90.0
button_min_coverage = 95.0
input_min_coverage = 95.0
```

### Environment Variables

Set environment variables in `.cargo/config.toml` or via shell:

```bash
# Coverage settings
export COVERAGE_MINIMUM_LINE_COVERAGE=95
export COVERAGE_MINIMUM_BRANCH_COVERAGE=90
export COVERAGE_MINIMUM_FUNCTION_COVERAGE=100

# Output settings
export COVERAGE_OUTPUT_DIR=coverage-reports
export COVERAGE_REPORT_TYPES=html,json,lcov

# Disable incremental compilation for accurate coverage
export CARGO_INCREMENTAL=0
```

## Report Formats

### HTML Report

Interactive HTML report with source-level coverage highlighting:

```bash
make coverage-html
# Output: coverage-reports/html/index.html
```

Features:
- Line-by-line coverage highlighting
- Branch coverage visualization
- Searchable component list
- Responsive design

### JSON Report

Machine-readable JSON for CI/CD integration:

```bash
make coverage-json
# Output: coverage-reports/coverage.json
```

Structure:
```json
{
  "timestamp": "2024-01-10T12:00:00Z",
  "git_branch": "main",
  "git_commit": "abc123",
  "overall": {
    "line_coverage": 95.5,
    "branch_coverage": 92.0,
    "function_coverage": 100.0
  },
  "components": [...]
}
```

### LCov Report

Standard LCov format for integration with coverage services:

```bash
make coverage-lcov
# Output: coverage-reports/coverage.lcov
```

### Terminal Report

Quick terminal summary:

```bash
make coverage-terminal
```

Output:
```
================================================================================
COVERAGE REPORT
================================================================================
Tool: llvm-cov
Branch: main
Commit: abc123

OVERALL METRICS
--------------------------------------------------------------------------------
overall: Lines: 95.5% (1523/1595), Branches: 92.0% (876/952), Functions: 100.0% (234/234)

COMPONENT METRICS
--------------------------------------------------------------------------------
button: Lines: 96.2% (127/132), ...
```

## CI/CD Integration

### GitHub Actions

The `.github/workflows/coverage-report.yml` workflow automatically:

1. Runs on every PR and push to main
2. Generates coverage reports
3. Posts coverage summary as PR comment
4. Uploads reports as artifacts
5. Fails PR if coverage is below threshold
6. Updates coverage badges

### Coverage Comments

PR comments include:
- Overall coverage percentage
- Pass/fail status
- Branch and commit info
- Link to full report

### Coverage Badges

Auto-generated badges are stored in `docs/badges/coverage.svg` and updated automatically on main branch builds.

Display in README:

```markdown
![Coverage](docs/badges/coverage.svg)
```

## Coverage Thresholds

### Default Thresholds

- **Line Coverage**: 95%
- **Branch Coverage**: 90%
- **Function Coverage**: 100%

### Component-Specific Thresholds

Some components have higher requirements:

```toml
[component_thresholds]
button_min_coverage = 95.0
input_min_coverage = 95.0
form_min_coverage = 95.0
```

### Quality Gates

Coverage gates are enforced in:
- CI/CD pipelines
- Pre-commit hooks
- Manual verification commands

## Troubleshooting

### Low Coverage Results

If coverage seems low:

1. **Check tool settings**: Different tools measure coverage differently
   ```bash
   # Use llvm-cov for comprehensive coverage
   ./scripts/generate_coverage_report.sh --tool llvm-cov
   ```

2. **Verify test execution**: Ensure tests are actually running
   ```bash
   cargo test --workspace
   ```

3. **Check exclusion patterns**: Review `.coverage-rules.toml` exclusions

### Missing Coverage Data

If reports are empty:

1. **Clean previous data**
   ```bash
   make clean
   rm -rf target/coverage
   ```

2. **Disable incremental compilation**
   ```bash
   export CARGO_INCREMENTAL=0
   ```

3. **Rebuild with coverage instrumentation**
   ```bash
   cargo clean
   ./scripts/generate_coverage_report.sh
   ```

### CI Failures

If CI fails on coverage:

1. **Check threshold settings** in `.coverage-rules.toml`
2. **Review coverage report** in GitHub Actions artifacts
3. **Compare with baseline** to identify degradation
4. **Update threshold** if appropriate (document reason)

## Best Practices

1. **Run locally first**: Check coverage before pushing
   ```bash
   make coverage-verify
   ```

2. **Review HTML reports**: Use HTML reports to identify gaps
   ```bash
   make coverage-html
   ```

3. **Monitor trends**: Track coverage over time
   ```bash
   make coverage-trend
   ```

4. **Set realistic thresholds**: Balance quality with development speed

5. **Document exceptions**: Use exclusions sparingly and document reasons

6. **Fix degradations**: Address coverage decreases promptly

## Advanced Usage

### Custom Coverage Tools

Integrate other coverage tools by extending `coverage_reporter.py`:

```python
class CustomCoverageTool(CoverageTool):
    def check_installed(self) -> bool:
        # Check if tool is installed
        pass

    def run_coverage(self, packages) -> CoverageReport:
        # Run coverage analysis
        pass
```

### Custom Report Formats

Add custom output formats in `ReportGenerator`:

```python
def generate_custom_report(self, report: CoverageReport) -> Path:
    # Generate custom format
    pass
```

### Historical Tracking

Enable trend analysis:

```bash
python3 scripts/coverage_reporter.py --trend
```

Historical data is stored in `coverage-history.json`.

## Support

For issues or questions:
- Check existing documentation in `docs/testing/`
- Review GitHub Actions logs
- Open an issue with coverage report attached

## Related Documentation

- [Testing Guide](../testing/testing-guide.md)
- [CI/CD Configuration](../ci/ci-configuration.md)
- [Quality Gates](../quality/quality-gates.md)
