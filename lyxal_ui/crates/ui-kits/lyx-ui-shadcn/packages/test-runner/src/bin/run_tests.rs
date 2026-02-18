//! Rust-based Test Runner Binary
//!
//! This is the proper way to run tests in a Rust project - using Rust!

use leptos_shadcn_test_runner::{TestRunner, TestSuiteResult};
use std::env;
use std::process;

fn main() {
println!("ðŸš€ Leptos ShadCN UI - Rust Test Runner");
println!("=====================================");

let args: Vec<String> = env::args().collect();
let command = args.get(1).map(|s| s.as_str()).unwrap_or("all");

let mut runner = TestRunner::new();

match command {
"all" => {
println!("ðŸ§ª Running all component tests...");
let results = runner.run_all_tests();
print_results(&results);
}
"coverage" => {
println!("ðŸ“Š Generating coverage report...");
runner.run_all_tests();
let coverage = runner.generate_coverage_report();
print_coverage_report(&coverage);
}
"summary" => {
println!("ðŸ“‹ Generating test summary...");
runner.run_all_tests();
let summary = runner.generate_summary_report();
println!("{}", summary);
}
"component" => {
if let Some(component_name) = args.get(2) {
println!("ðŸ§ª Running tests for component: {}", component_name);
let result = runner.run_component_tests(component_name);
print_single_result(&result);
} else {
eprintln!("âŒ Please specify a component name");
process::exit(1);
}
}
"export" => {
println!("ðŸ“„ Exporting test results...");
runner.run_all_tests();
let results_json = runner.export_results_json();
let coverage_json = runner.export_coverage_json();

std::fs::write("test_results.json", results_json)
.expect("Failed to write test results");
std::fs::write("coverage_report.json", coverage_json)
.expect("Failed to write coverage report");

println!("âœ… Results exported to test_results.json and coverage_report.json");
}
_ => {
print_usage();
process::exit(1);
}
}
}

fn print_results(results: &[TestSuiteResult]) {
println!("\nðŸ“Š Test Results Summary");
println!("=======================");

let total_tests: usize = results.iter().map(|r| r.total_tests).sum();
let total_passed: usize = results.iter().map(|r| r.passed_tests).sum();
let total_failed: usize = results.iter().map(|r| r.failed_tests).sum();
let total_duration: std::time::Duration = results.iter().map(|r| r.total_duration).sum();

println!("ðŸ“¦ Total Test Suites: {}", results.len());
println!("ðŸ§ª Total Tests: {}", total_tests);
println!("âœ… Passed: {}", total_passed);
println!("âŒ Failed: {}", total_failed);
println!("â±ï¸  Total Duration: {:?}", total_duration);

if total_failed == 0 {
println!("\nðŸŽ‰ All tests passed!");
} else {
println!("\nâš ï¸  Some tests failed:");
for result in results {
if result.failed_tests > 0 {
println!("   âŒ {}: {} failed", result.suite_name, result.failed_tests);
}
}
}
}

fn print_single_result(result: &TestSuiteResult) {
println!("\nðŸ“Š Test Results for {}", result.suite_name);
println!("=====================================");
println!("ðŸ§ª Total Tests: {}", result.total_tests);
println!("âœ… Passed: {}", result.passed_tests);
println!("âŒ Failed: {}", result.failed_tests);
println!("â­ï¸  Skipped: {}", result.skipped_tests);
println!("â±ï¸  Duration: {:?}", result.total_duration);

if result.failed_tests > 0 {
println!("\nâŒ Failed Tests:");
for test_result in &result.results {
if matches!(test_result.status, leptos_shadcn_test_runner::TestStatus::Failed) {
println!("   - {}: {}", test_result.test_name,
test_result.error_message.as_deref().unwrap_or("Unknown error"));
}
}
}
}

fn print_coverage_report(coverage: &std::collections::HashMap<String, leptos_shadcn_test_runner::CoverageReport>) {
println!("\nðŸ“Š Coverage Report");
println!("==================");

let mut total_real_tests = 0;
let mut total_wasm_tests = 0;
let mut total_placeholder_tests = 0;
let mut total_tests = 0;

for (component, report) in coverage {
println!("ðŸ“¦ {}:", component);
println!("   ðŸ§ª Total Tests: {}", report.total_tests);
println!("   âœ… Real Tests: {}", report.real_tests);
println!("   ðŸŒ WASM Tests: {}", report.wasm_tests);
println!("   âŒ Placeholder Tests: {}", report.placeholder_tests);
println!("   ðŸ“ˆ Coverage: {:.1}%", report.coverage_percentage);
println!();

total_real_tests += report.real_tests;
total_wasm_tests += report.wasm_tests;
total_placeholder_tests += report.placeholder_tests;
total_tests += report.total_tests;
}

let overall_coverage = if total_tests > 0 {
(total_real_tests as f64 / total_tests as f64) * 100.0
} else {
0.0
};

println!("ðŸŽ¯ Overall Coverage Summary:");
println!("   ðŸ“¦ Total Components: {}", coverage.len());
println!("   ðŸ§ª Total Tests: {}", total_tests);
println!("   âœ… Real Tests: {}", total_real_tests);
println!("   ðŸŒ WASM Tests: {}", total_wasm_tests);
println!("   âŒ Placeholder Tests: {}", total_placeholder_tests);
println!("   ðŸ“ˆ Overall Coverage: {:.1}%", overall_coverage);

if overall_coverage >= 90.0 {
println!("\nðŸŽ‰ Excellent coverage! Target achieved!");
} else if overall_coverage >= 75.0 {
println!("\nâœ… Good coverage, room for improvement");
} else {
println!("\nâš ï¸  Coverage needs improvement");
}
}

fn print_usage() {
println!("Usage: cargo run --bin run_tests [COMMAND] [OPTIONS]");
println!();
println!("Commands:");
println!("  all                    Run all component tests (default)");
println!("  coverage               Generate coverage report");
println!("  summary                Generate test summary");
println!("  component <name>       Run tests for specific component");
println!("  export                 Export results to JSON files");
println!();
println!("Examples:");
println!("  cargo run --bin run_tests");
println!("  cargo run --bin run_tests coverage");
println!("  cargo run --bin run_tests component button");
println!("  cargo run --bin run_tests export");
}
