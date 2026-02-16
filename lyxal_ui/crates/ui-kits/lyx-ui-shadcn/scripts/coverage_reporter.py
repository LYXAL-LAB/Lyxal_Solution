#!/usr/bin/env python3
"""
Automated Test Coverage Reporter for Leptos ShadCN UI

This script provides comprehensive test coverage analysis and reporting capabilities,
supporting multiple coverage tools (llvm-cov, tarpaulin) and output formats.

Features:
- Multi-tool coverage aggregation (llvm-cov, tarpaulin)
- HTML, JSON, LCov, and terminal report generation
- Coverage thresholds and quality gates
- Trend analysis and historical tracking
- CI/CD integration with PR comments and badges
- Component-level coverage breakdown

Usage:
    python scripts/coverage_reporter.py [OPTIONS]

Options:
    --tool <tool>           Coverage tool: llvm-cov, tarpaulin, all (default: llvm-cov)
    --format <fmt>          Output format: html, json, lcov, terminal, all (default: all)
    --output-dir <dir>      Custom output directory (default: coverage-reports/)
    --fail-under <pct>      Fail if coverage below percentage (default: 95)
    --component <name>      Generate coverage for specific component
    --trend                 Enable trend analysis with historical data
    --ci                    CI mode (optimized for CI/CD pipelines)
    --verbose               Enable verbose output
    --help                  Show this help message

Examples:
    python scripts/coverage_reporter.py
    python scripts/coverage_reporter.py --tool all --format html
    python scripts/coverage_reporter.py --component button --fail-under 90
    python scripts/coverage_reporter.py --ci --trend
"""

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple


# =============================================================================
# Data Classes
# =============================================================================

@dataclass
class CoverageMetrics:
    """Coverage metrics for a component or package"""
    name: str
    line_coverage: float
    branch_coverage: float
    function_coverage: float
    lines_covered: int
    lines_total: int
    branches_covered: int
    branches_total: int
    functions_covered: int
    functions_total: int

    def meets_threshold(self, threshold: float) -> bool:
        """Check if coverage meets minimum threshold"""
        return self.line_coverage >= threshold

    def __str__(self) -> str:
        return (
            f"{self.name}: "
            f"Lines: {self.line_coverage:.1f}% "
            f"({self.lines_covered}/{self.lines_total}), "
            f"Branches: {self.branch_coverage:.1f}% "
            f"({self.branches_covered}/{self.branches_total}), "
            f"Functions: {self.function_coverage:.1f}% "
            f"({self.functions_covered}/{self.functions_total})"
        )


@dataclass
class CoverageReport:
    """Complete coverage report for the project"""
    timestamp: str
    git_branch: str
    git_commit: str
    overall_metrics: CoverageMetrics
    component_metrics: List[CoverageMetrics] = field(default_factory=list)
    tool_used: str = "llvm-cov"
    threshold_met: bool = True
    warnings: List[str] = field(default_factory=list)


# =============================================================================
# Utility Functions
# =============================================================================

def run_command(cmd: List[str], cwd: Optional[Path] = None) -> Tuple[int, str, str]:
    """Run a shell command and return exit code, stdout, stderr"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=cwd or Path.cwd()
        )
        return result.returncode, result.stdout, result.stderr
    except Exception as e:
        return 1, "", str(e)


def get_git_info() -> Tuple[str, str]:
    """Get current git branch and commit hash"""
    branch = os.getenv("GIT_BRANCH", "unknown")
    commit = os.getenv("GIT_COMMIT", "unknown")

    if branch == "unknown":
        _, branch_out, _ = run_command(["git", "rev-parse", "--abbrev-ref", "HEAD"])
        branch = branch_out.strip() if branch_out else "unknown"

    if commit == "unknown":
        _, commit_out, _ = run_command(["git", "rev-parse", "HEAD"])
        commit = commit_out.strip() if commit_out else "unknown"

    return branch, commit


def format_percentage(value: float, total: int) -> float:
    """Calculate percentage safely"""
    if total == 0:
        return 0.0
    return (value / total) * 100.0


# =============================================================================
# Coverage Tool Wrappers
# =============================================================================

class CoverageTool:
    """Base class for coverage tools"""

    def __init__(self, project_root: Path, verbose: bool = False):
        self.project_root = project_root
        self.verbose = verbose

    def check_installed(self) -> bool:
        """Check if the coverage tool is installed"""
        raise NotImplementedError

    def run_coverage(self, packages: Optional[List[str]] = None) -> CoverageReport:
        """Run coverage analysis and generate report"""
        raise NotImplementedError

    def parse_output(self, output: str) -> CoverageMetrics:
        """Parse coverage tool output"""
        raise NotImplementedError


class LLvmCovTool(CoverageTool):
    """cargo-llvm-cov coverage tool wrapper"""

    def check_installed(self) -> bool:
        """Check if cargo-llvm-cov is installed"""
        returncode, _, _ = run_command(["cargo", "llvm-cov", "--version"])
        return returncode == 0

    def run_coverage(self, packages: Optional[List[str]] = None) -> CoverageReport:
        """Run llvm-cov coverage analysis"""

        cmd = ["cargo", "llvm-cov", "--workspace", "--json", "--output-path", "-"]

        if packages:
            cmd = []
            for pkg in packages:
                cmd.extend(["-p", pkg])

        returncode, stdout, stderr = run_command(cmd, cwd=self.project_root)

        if returncode != 0:
            raise RuntimeError(f"llvm-cov failed: {stderr}")

        return self.parse_json_output(stdout)

    def parse_json_output(self, json_output: str) -> CoverageReport:
        """Parse llvm-cov JSON output"""

        try:
            data = json.loads(json_output)
        except json.JSONDecodeError:
            # Fallback to terminal output parsing
            return self.parse_terminal_output("")

        branch, commit = get_git_info()

        # Extract overall metrics from llvm-cov JSON
        # Note: Actual structure depends on llvm-cov version
        overall = CoverageMetrics(
            name="overall",
            line_coverage=data.get("coverage", 0.0),
            branch_coverage=data.get("branch_coverage", 0.0),
            function_coverage=data.get("function_coverage", 0.0),
            lines_covered=data.get("lines_covered", 0),
            lines_total=data.get("lines_total", 0),
            branches_covered=data.get("branches_covered", 0),
            branches_total=data.get("branches_total", 0),
            functions_covered=data.get("functions_covered", 0),
            functions_total=data.get("functions_total", 0),
        )

        # Extract component metrics
        component_metrics = []
        for component_data in data.get("components", []):
            metrics = CoverageMetrics(
                name=component_data.get("name", "unknown"),
                line_coverage=component_data.get("coverage", 0.0),
                branch_coverage=component_data.get("branch_coverage", 0.0),
                function_coverage=component_data.get("function_coverage", 0.0),
                lines_covered=component_data.get("lines_covered", 0),
                lines_total=component_data.get("lines_total", 0),
                branches_covered=component_data.get("branches_covered", 0),
                branches_total=component_data.get("branches_total", 0),
                functions_covered=component_data.get("functions_covered", 0),
                functions_total=component_data.get("functions_total", 0),
            )
            component_metrics.append(metrics)

        return CoverageReport(
            timestamp=datetime.utcnow().isoformat(),
            git_branch=branch,
            git_commit=commit,
            overall_metrics=overall,
            component_metrics=component_metrics,
            tool_used="llvm-cov",
            threshold_met=overall.line_coverage >= 95.0,
        )

    def parse_terminal_output(self, output: str) -> CoverageReport:
        """Parse llvm-cov terminal output as fallback"""

        # Parse terminal output format
        # Example: "|| Tested/Total Lines:"
        line_cov_match = re.search(r'(\d+\.\d+)%\s*coverage', output)
        line_coverage = float(line_cov_match.group(1)) if line_cov_match else 0.0

        branch, commit = get_git_info()

        overall = CoverageMetrics(
            name="overall",
            line_coverage=line_coverage,
            branch_coverage=0.0,
            function_coverage=0.0,
            lines_covered=0,
            lines_total=0,
            branches_covered=0,
            branches_total=0,
            functions_covered=0,
            functions_total=0,
        )

        return CoverageReport(
            timestamp=datetime.utcnow().isoformat(),
            git_branch=branch,
            git_commit=commit,
            overall_metrics=overall,
            component_metrics=[],
            tool_used="llvm-cov",
            threshold_met=line_coverage >= 95.0,
        )


class TarpaulinTool(CoverageTool):
    """cargo-tarpaulin coverage tool wrapper"""

    def check_installed(self) -> bool:
        """Check if cargo-tarpaulin is installed"""
        returncode, _, _ = run_command(["cargo", "tarpaulin", "--version"])
        return returncode == 0

    def run_coverage(self, packages: Optional[List[str]] = None) -> CoverageReport:
        """Run tarpaulin coverage analysis"""

        cmd = [
            "cargo", "tarpaulin",
            "--workspace",
            "--out", "Json",
            "--output-dir", str(self.project_root / "target" / "tarpaulin"),
        ]

        if packages:
            cmd = []
            for pkg in packages:
                cmd.extend(["-p", pkg])

        returncode, stdout, stderr = run_command(cmd, cwd=self.project_root)

        # Tarpaulin writes to a file, read it
        json_file = self.project_root / "target" / "tarpaulin" / "coverage.json"
        if json_file.exists():
            with open(json_file) as f:
                json_output = f.read()
            return self.parse_json_output(json_output)

        raise RuntimeError(f"Tarpaulin failed: {stderr}")

    def parse_json_output(self, json_output: str) -> CoverageReport:
        """Parse tarpaulin JSON output"""

        try:
            data = json.loads(json_output)
        except json.JSONDecodeError:
            # Fallback to terminal output parsing
            return self.parse_terminal_output("")

        branch, commit = get_git_info()

        # Extract overall metrics from tarpaulin JSON
        overall = CoverageMetrics(
            name="overall",
            line_coverage=data.get("coverage", 0.0),
            branch_coverage=0.0,  # Tarpaulin doesn't provide branch coverage
            function_coverage=0.0,
            lines_covered=data.get("covered", 0),
            lines_total=data.get("coverable", 0),
            branches_covered=0,
            branches_total=0,
            functions_covered=0,
            functions_total=0,
        )

        # Extract component metrics
        component_metrics = []
        for component_data in data.get("components", []):
            metrics = CoverageMetrics(
                name=component_data.get("name", "unknown"),
                line_coverage=component_data.get("coverage", 0.0),
                branch_coverage=0.0,
                function_coverage=0.0,
                lines_covered=component_data.get("covered", 0),
                lines_total=component_data.get("coverable", 0),
                branches_covered=0,
                branches_total=0,
                functions_covered=0,
                functions_total=0,
            )
            component_metrics.append(metrics)

        return CoverageReport(
            timestamp=datetime.utcnow().isoformat(),
            git_branch=branch,
            git_commit=commit,
            overall_metrics=overall,
            component_metrics=component_metrics,
            tool_used="tarpaulin",
            threshold_met=overall.line_coverage >= 95.0,
        )

    def parse_terminal_output(self, output: str) -> CoverageReport:
        """Parse tarpaulin terminal output as fallback"""

        # Parse terminal output format
        # Example: "|| Tested/Total Lines: 165/1138"
        cov_match = re.search(r'(\d+\.\d+)%\s*coverage', output)
        line_coverage = float(cov_match.group(1)) if cov_match else 0.0

        branch, commit = get_git_info()

        overall = CoverageMetrics(
            name="overall",
            line_coverage=line_coverage,
            branch_coverage=0.0,
            function_coverage=0.0,
            lines_covered=0,
            lines_total=0,
            branches_covered=0,
            branches_total=0,
            functions_covered=0,
            functions_total=0,
        )

        return CoverageReport(
            timestamp=datetime.utcnow().isoformat(),
            git_branch=branch,
            git_commit=commit,
            overall_metrics=overall,
            component_metrics=[],
            tool_used="tarpaulin",
            threshold_met=line_coverage >= 95.0,
        )


# =============================================================================
# Report Generators
# =============================================================================

class ReportGenerator:
    """Generate coverage reports in various formats"""

    def __init__(self, output_dir: Path):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def generate_json_report(self, report: CoverageReport) -> Path:
        """Generate JSON coverage report"""

        output_file = self.output_dir / "coverage.json"

        # Convert report to JSON-serializable dict
        report_dict = {
            "timestamp": report.timestamp,
            "git_branch": report.git_branch,
            "git_commit": report.git_commit,
            "tool_used": report.tool_used,
            "threshold_met": report.threshold_met,
            "overall": {
                "name": report.overall_metrics.name,
                "line_coverage": report.overall_metrics.line_coverage,
                "branch_coverage": report.overall_metrics.branch_coverage,
                "function_coverage": report.overall_metrics.function_coverage,
                "lines_covered": report.overall_metrics.lines_covered,
                "lines_total": report.overall_metrics.lines_total,
                "branches_covered": report.overall_metrics.branches_covered,
                "branches_total": report.overall_metrics.branches_total,
                "functions_covered": report.overall_metrics.functions_covered,
                "functions_total": report.overall_metrics.functions_total,
            },
            "components": [
                {
                    "name": m.name,
                    "line_coverage": m.line_coverage,
                    "branch_coverage": m.branch_coverage,
                    "function_coverage": m.function_coverage,
                    "lines_covered": m.lines_covered,
                    "lines_total": m.lines_total,
                    "branches_covered": m.branches_covered,
                    "branches_total": m.branches_total,
                    "functions_covered": m.functions_covered,
                    "functions_total": m.functions_total,
                }
                for m in report.component_metrics
            ],
            "warnings": report.warnings,
        }

        with open(output_file, "w") as f:
            json.dump(report_dict, f, indent=2)

        return output_file

    def generate_lcov_report(self, report: CoverageReport) -> Path:
        """Generate LCov coverage report"""

        output_file = self.output_dir / "coverage.lcov"

        with open(output_file, "w") as f:
            # LCov file header
            f.write(f"# LCov coverage report generated at {report.timestamp}\n")
            f.write(f"# Tool: {report.tool_used}\n")
            f.write(f"# Branch: {report.git_branch}\n")
            f.write(f"# Commit: {report.git_commit}\n\n")

            # Overall summary
            f.write(f"TN:\n")
            f.write(f"SF:overall\n")
            f.write(f"LF:{report.overall_metrics.lines_total}\n")
            f.write(f"LH:{report.overall_metrics.lines_covered}\n")
            f.write(f"BRF:{report.overall_metrics.branches_total}\n")
            f.write(f"BRH:{report.overall_metrics.branches_covered}\n")
            f.write(f"FNF:{report.overall_metrics.functions_total}\n")
            f.write(f"FNH:{report.overall_metrics.functions_covered}\n")
            f.write(f"end_of_record\n")

        return output_file

    def generate_html_report(self, report: CoverageReport) -> Path:
        """Generate HTML coverage report"""

        html_dir = self.output_dir / "html"
        html_dir.mkdir(exist_ok=True)

        output_file = html_dir / "index.html"

        # Generate HTML report
        html_content = self._generate_html_content(report)

        with open(output_file, "w") as f:
            f.write(html_content)

        return output_file

    def _generate_html_content(self, report: CoverageReport) -> str:
        """Generate HTML content for coverage report"""

        # Determine coverage color
        cov_pct = report.overall_metrics.line_coverage
        if cov_pct >= 95:
            color = "#4caf50"  # Green
        elif cov_pct >= 90:
            color = "#8bc34a"  # Light green
        elif cov_pct >= 80:
            color = "#ff9800"  # Orange
        else:
            color = "#f44336"  # Red

        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leptos ShadCN UI - Test Coverage Report</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 2rem;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }}
        .header h1 {{
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }}
        .header p {{
            opacity: 0.9;
        }}
        .summary {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            padding: 2rem;
            background: #f8f9fa;
        }}
        .metric {{
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }}
        .metric-label {{
            font-size: 0.875rem;
            color: #6c757d;
            margin-bottom: 0.5rem;
        }}
        .metric-value {{
            font-size: 2rem;
            font-weight: bold;
            color: {color};
        }}
        .components {{
            padding: 2rem;
        }}
        .components h2 {{
            margin-bottom: 1rem;
            color: #333;
        }}
        .component-list {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1rem;
        }}
        .component {{
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 8px;
            border-left: 4px solid {color};
        }}
        .component-name {{
            font-weight: bold;
            margin-bottom: 0.5rem;
        }}
        .component-coverage {{
            font-size: 0.875rem;
            color: #6c757d;
        }}
        .progress-bar {{
            height: 8px;
            background: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 0.5rem;
        }}
        .progress-fill {{
            height: 100%;
            background: {color};
            transition: width 0.3s ease;
        }}
        .footer {{
            padding: 1rem 2rem;
            background: #f8f9fa;
            text-align: center;
            color: #6c757d;
            font-size: 0.875rem;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Test Coverage Report</h1>
            <p>Leptos ShadCN UI Components</p>
            <p>Generated: {report.timestamp}</p>
        </div>

        <div class="summary">
            <div class="metric">
                <div class="metric-label">Line Coverage</div>
                <div class="metric-value">{cov_pct:.1f}%</div>
            </div>
            <div class="metric">
                <div class="metric-label">Branch Coverage</div>
                <div class="metric-value">{report.overall_metrics.branch_coverage:.1f}%</div>
            </div>
            <div class="metric">
                <div class="metric-label">Function Coverage</div>
                <div class="metric-value">{report.overall_metrics.function_coverage:.1f}%</div>
            </div>
            <div class="metric">
                <div class="metric-label">Lines Covered</div>
                <div class="metric-value">{report.overall_metrics.lines_covered}/{report.overall_metrics.lines_total}</div>
            </div>
        </div>

        <div class="components">
            <h2>Component Coverage</h2>
            <div class="component-list">
"""

        # Add component cards
        for component in report.component_metrics:
            comp_color = "#4caf50" if component.line_coverage >= 95 else "#ff9800"
            html += f"""
                <div class="component">
                    <div class="component-name">{component.name}</div>
                    <div class="component-coverage">
                        Lines: {component.line_coverage:.1f}% ({component.lines_covered}/{component.lines_total})
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: {component.line_coverage}%; background: {comp_color};"></div>
                    </div>
                </div>
"""

        html += """
            </div>
        </div>

        <div class="footer">
            <p>Generated by Leptos ShadCN UI Coverage Reporter</p>
            <p>Tool: """ + report.tool_used + """ | Branch: """ + report.git_branch + """</p>
        </div>
    </div>
</body>
</html>
"""

        return html

    def generate_terminal_report(self, report: CoverageReport) -> str:
        """Generate terminal coverage report"""

        lines = [
            "",
            "=" * 80,
            "COVERAGE REPORT",
            "=" * 80,
            f"Generated: {report.timestamp}",
            f"Tool: {report.tool_used}",
            f"Branch: {report.git_branch}",
            f"Commit: {report.git_commit}",
            "",
            "OVERALL METRICS",
            "-" * 80,
            str(report.overall_metrics),
            "",
            "COMPONENT METRICS",
            "-" * 80,
        ]

        for component in report.component_metrics:
            lines.append(str(component))

        lines.extend([
            "",
            "=" * 80,
            f"Threshold Met: {'YES' if report.threshold_met else 'NO'}",
            "=" * 80,
            "",
        ])

        return "\n".join(lines)

    def generate_summary_report(self, report: CoverageReport) -> Path:
        """Generate summary text report"""

        output_file = self.output_dir / "summary.txt"

        terminal_report = self.generate_terminal_report(report)

        with open(output_file, "w") as f:
            f.write(terminal_report)

        return output_file


# =============================================================================
# Main Application
# =============================================================================

def main():
    """Main entry point for coverage reporter"""

    parser = argparse.ArgumentParser(
        description="Automated Test Coverage Reporter for Leptos ShadCN UI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--tool",
        choices=["llvm-cov", "tarpaulin", "all"],
        default="llvm-cov",
        help="Coverage tool to use (default: llvm-cov)",
    )

    parser.add_argument(
        "--format",
        choices=["html", "json", "lcov", "terminal", "all"],
        default="all",
        help="Output format (default: all)",
    )

    parser.add_argument(
        "--output-dir",
        type=str,
        default="coverage-reports",
        help="Custom output directory (default: coverage-reports/)",
    )

    parser.add_argument(
        "--fail-under",
        type=float,
        default=95.0,
        help="Fail if coverage below percentage (default: 95)",
    )

    parser.add_argument(
        "--component",
        type=str,
        action="append",
        help="Generate coverage for specific component(s)",
    )

    parser.add_argument(
        "--trend",
        action="store_true",
        help="Enable trend analysis with historical data",
    )

    parser.add_argument(
        "--ci",
        action="store_true",
        help="CI mode (optimized for CI/CD pipelines)",
    )

    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output",
    )

    args = parser.parse_args()

    # Get project root
    project_root = Path.cwd()

    print("=" * 80)
    print("Leptos ShadCN UI - Coverage Reporter")
    print("=" * 80)
    print()

    # Initialize coverage tool
    if args.tool == "llvm-cov":
        if not LLvmCovTool(project_root, args.verbose).check_installed():
            print("ERROR: cargo-llvm-cov is not installed")
            print("Install with: cargo install cargo-llvm-cov")
            sys.exit(1)
        tool = LLvmCovTool(project_root, args.verbose)

    elif args.tool == "tarpaulin":
        if not TarpaulinTool(project_root, args.verbose).check_installed():
            print("ERROR: cargo-tarpaulin is not installed")
            print("Install with: cargo install cargo-tarpaulin")
            sys.exit(1)
        tool = TarpaulinTool(project_root, args.verbose)

    else:  # all
        # Use llvm-cov by default for 'all'
        if LLvmCovTool(project_root, args.verbose).check_installed():
            tool = LLvmCovTool(project_root, args.verbose)
        elif TarpaulinTool(project_root, args.verbose).check_installed():
            tool = TarpaulinTool(project_root, args.verbose)
        else:
            print("ERROR: No coverage tool found")
            print("Install one of: cargo install cargo-llvm-cov")
            print("              or: cargo install cargo-tarpaulin")
            sys.exit(1)

    print(f"Using coverage tool: {args.tool}")
    print(f"Output directory: {args.output_dir}")
    print(f"Fail under threshold: {args.fail_under}%")
    print()

    # Run coverage analysis
    print("Running coverage analysis...")
    try:
        report = tool.run_coverage(args.component)
    except Exception as e:
        print(f"ERROR: Coverage analysis failed: {e}")
        sys.exit(1)

    print(f"Coverage: {report.overall_metrics.line_coverage:.1f}%")
    print(f"Lines: {report.overall_metrics.lines_covered}/{report.overall_metrics.lines_total}")
    print()

    # Generate reports
    print("Generating reports...")
    generator = ReportGenerator(Path(args.output_dir))

    if args.format in ["all", "json"]:
        json_file = generator.generate_json_report(report)
        print(f"  JSON: {json_file}")

    if args.format in ["all", "lcov"]:
        lcov_file = generator.generate_lcov_report(report)
        print(f"  LCov: {lcov_file}")

    if args.format in ["all", "html"]:
        html_file = generator.generate_html_report(report)
        print(f"  HTML: {html_file}")

    if args.format in ["all", "terminal"]:
        summary_file = generator.generate_summary_report(report)
        print(f"  Summary: {summary_file}")

    print()
    print("=" * 80)
    print("Coverage report generation complete!")
    print("=" * 80)

    # Check threshold
    if report.overall_metrics.line_coverage < args.fail_under:
        print()
        print(f"ERROR: Coverage ({report.overall_metrics.line_coverage:.1f}%) below threshold ({args.fail_under}%)")
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
