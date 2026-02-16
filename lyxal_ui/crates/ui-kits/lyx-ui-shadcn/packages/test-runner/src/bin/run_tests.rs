//! Rust-based Test Runner Binary
//! 
//! This is the proper way to run tests in a Rust project - using Rust!

use leptos_shadcn_test_runner::{TestRunner, TestSuiteResult};
use std::env;
use std::process;

fn main() {
    println!("🚀 Leptos ShadCN UI - Rust Test Runner");
    println!("=====================================");
    
    let args: Vec<String> = env::args().collect();
    let command = args.get(1).map(|s| s.as_str()).unwrap_or("all");
    
    let mut runner = TestRunner::new();
    
    match command {
        "all" => {
            println!("🧪 Running all component tests...");
            let results = runner.run_all_tests();
            print_results(&results);
        }
        "coverage" => {
            println!("📊 Generating coverage report...");
            runner.run_all_tests();
            let coverage = runner.generate_coverage_report();
            print_coverage_report(&coverage);
        }
        "summary" => {
            println!("📋 Generating test summary...");
            runner.run_all_tests();
            let summary = runner.generate_summary_report();
            println!("{}", summary);
        }
        "component" => {
            if let Some(component_name) = args.get(2) {
                println!("🧪 Running tests for component: {}", component_name);
                let result = runner.run_component_tests(component_name);
                print_single_result(&result);
            } else {
                eprintln!("❌ Please specify a component name");
                process::exit(1);
            }
        }
        "export" => {
            println!("📄 Exporting test results...");
            runner.run_all_tests();
            let results_json = runner.export_results_json();
            let coverage_json = runner.export_coverage_json();
            
            std::fs::write("test_results.json", results_json)
                .expect("Failed to write test results");
            std::fs::write("coverage_report.json", coverage_json)
                .expect("Failed to write coverage report");
            
            println!("✅ Results exported to test_results.json and coverage_report.json");
        }
        _ => {
            print_usage();
            process::exit(1);
        }
    }
}

fn print_results(results: &[TestSuiteResult]) {
    println!("\n📊 Test Results Summary");
    println!("=======================");
    
    let total_tests: usize = results.iter().map(|r| r.total_tests).sum();
    let total_passed: usize = results.iter().map(|r| r.passed_tests).sum();
    let total_failed: usize = results.iter().map(|r| r.failed_tests).sum();
    let total_duration: std::time::Duration = results.iter().map(|r| r.total_duration).sum();
    
    println!("📦 Total Test Suites: {}", results.len());
    println!("🧪 Total Tests: {}", total_tests);
    println!("✅ Passed: {}", total_passed);
    println!("❌ Failed: {}", total_failed);
    println!("⏱️  Total Duration: {:?}", total_duration);
    
    if total_failed == 0 {
        println!("\n🎉 All tests passed!");
    } else {
        println!("\n⚠️  Some tests failed:");
        for result in results {
            if result.failed_tests > 0 {
                println!("   ❌ {}: {} failed", result.suite_name, result.failed_tests);
            }
        }
    }
}

fn print_single_result(result: &TestSuiteResult) {
    println!("\n📊 Test Results for {}", result.suite_name);
    println!("=====================================");
    println!("🧪 Total Tests: {}", result.total_tests);
    println!("✅ Passed: {}", result.passed_tests);
    println!("❌ Failed: {}", result.failed_tests);
    println!("⏭️  Skipped: {}", result.skipped_tests);
    println!("⏱️  Duration: {:?}", result.total_duration);
    
    if result.failed_tests > 0 {
        println!("\n❌ Failed Tests:");
        for test_result in &result.results {
            if matches!(test_result.status, leptos_shadcn_test_runner::TestStatus::Failed) {
                println!("   - {}: {}", test_result.test_name, 
                    test_result.error_message.as_deref().unwrap_or("Unknown error"));
            }
        }
    }
}

fn print_coverage_report(coverage: &std::collections::HashMap<String, leptos_shadcn_test_runner::CoverageReport>) {
    println!("\n📊 Coverage Report");
    println!("==================");
    
    let mut total_real_tests = 0;
    let mut total_wasm_tests = 0;
    let mut total_placeholder_tests = 0;
    let mut total_tests = 0;
    
    for (component, report) in coverage {
        println!("📦 {}:", component);
        println!("   🧪 Total Tests: {}", report.total_tests);
        println!("   ✅ Real Tests: {}", report.real_tests);
        println!("   🌐 WASM Tests: {}", report.wasm_tests);
        println!("   ❌ Placeholder Tests: {}", report.placeholder_tests);
        println!("   📈 Coverage: {:.1}%", report.coverage_percentage);
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
    
    println!("🎯 Overall Coverage Summary:");
    println!("   📦 Total Components: {}", coverage.len());
    println!("   🧪 Total Tests: {}", total_tests);
    println!("   ✅ Real Tests: {}", total_real_tests);
    println!("   🌐 WASM Tests: {}", total_wasm_tests);
    println!("   ❌ Placeholder Tests: {}", total_placeholder_tests);
    println!("   📈 Overall Coverage: {:.1}%", overall_coverage);
    
    if overall_coverage >= 90.0 {
        println!("\n🎉 Excellent coverage! Target achieved!");
    } else if overall_coverage >= 75.0 {
        println!("\n✅ Good coverage, room for improvement");
    } else {
        println!("\n⚠️  Coverage needs improvement");
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

```
```
```
```
```
```
```
```
```
```
```
```
```
```

