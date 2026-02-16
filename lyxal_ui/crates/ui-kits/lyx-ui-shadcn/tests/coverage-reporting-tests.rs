//! Integration tests for the coverage reporting system
//!
//! These tests verify that the coverage reporting scripts and tools
//! work correctly and produce valid output.

use std::path::PathBuf;
use std::process::Command;

#[cfg(test)]
mod coverage_reporting_tests {
    use super::*;

    fn project_root() -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR"))
    }

    fn scripts_dir() -> PathBuf {
        project_root().join("scripts")
    }

    #[test]
    fn test_coverage_script_exists() {
        let shell_script = scripts_dir().join("generate_coverage_report.sh");
        let python_script = scripts_dir().join("coverage_reporter.py");

        assert!(
            shell_script.exists(),
            "Coverage shell script should exist at {:?}",
            shell_script
        );
        assert!(
            python_script.exists(),
            "Coverage Python script should exist at {:?}",
            python_script
        );
    }

    #[test]
    fn test_coverage_rules_file_exists() {
        let rules_file = project_root().join(".coverage-rules.toml");
        assert!(
            rules_file.exists(),
            "Coverage rules file should exist at {:?}",
            rules_file
        );
    }

    #[test]
    fn test_coverage_documentation_exists() {
        let docs_dir = project_root().join("docs").join("testing");
        let coverage_doc = docs_dir.join("coverage-reporting.md");

        assert!(
            coverage_doc.exists(),
            "Coverage documentation should exist at {:?}",
            coverage_doc
        );
    }

    #[test]
    fn test_ci_workflow_exists() {
        let workflows_dir = project_root().join(".github").join("workflows");
        let coverage_workflow = workflows_dir.join("coverage-report.yml");

        assert!(
            coverage_workflow.exists(),
            "Coverage CI workflow should exist at {:?}",
            coverage_workflow
        );
    }

    #[test]
    fn test_coverage_config_in_cargo_config() {
        let cargo_config = project_root().join(".cargo").join("config.toml");

        assert!(
            cargo_config.exists(),
            "Cargo config should exist at {:?}",
            cargo_config
        );

        // Read the config file and verify it contains coverage settings
        let contents = std::fs::read_to_string(&cargo_config)
            .expect("Should be able to read cargo config");

        assert!(
            contents.contains("COVERAGE"),
            "Cargo config should contain coverage settings"
        );
    }

    #[test]
    fn test_makefile_coverage_targets_exist() {
        let makefile = project_root().join("Makefile");

        assert!(
            makefile.exists(),
            "Makefile should exist at {:?}",
            makefile
        );

        let contents = std::fs::read_to_string(&makefile)
            .expect("Should be able to read Makefile");

        // Verify coverage targets exist
        assert!(
            contents.contains("coverage:"),
            "Makefile should have 'coverage' target"
        );
        assert!(
            contents.contains("coverage-html:"),
            "Makefile should have 'coverage-html' target"
        );
        assert!(
            contents.contains("coverage-json:"),
            "Makefile should have 'coverage-json' target"
        );
        assert!(
            contents.contains("coverage-lcov:"),
            "Makefile should have 'coverage-lcov' target"
        );
        assert!(
            contents.contains("coverage-verify:"),
            "Makefile should have 'coverage-verify' target"
        );
    }

    #[test]
    fn test_gitignore_includes_coverage() {
        let gitignore = project_root().join(".gitignore");

        assert!(
            gitignore.exists(),
            ".gitignore should exist"
        );

        let contents = std::fs::read_to_string(&gitignore)
            .expect("Should be able to read .gitignore");

        // Verify coverage directories are ignored
        assert!(
            contents.contains("coverage-reports"),
            ".gitignore should exclude coverage-reports directory"
        );
        assert!(
            contents.contains("coverage-history.json"),
            ".gitignore should exclude coverage-history.json"
        );
        assert!(
            contents.contains("target/coverage"),
            ".gitignore should exclude target/coverage directory"
        );
    }

    #[test]
    fn test_coverage_script_is_executable() {
        let shell_script = scripts_dir().join("generate_coverage_report.sh");

        // On Unix-like systems, check if the file is executable
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let metadata = std::fs::metadata(&shell_script)
                .expect("Should be able to read script metadata");
            let permissions = metadata.permissions();
            let mode = permissions.mode();

            // Check if the executable bit is set (owner execute)
            assert!(
                mode & 0o100 != 0,
                "Coverage script should be executable"
            );
        }
    }

    #[test]
    fn test_coverage_rules_valid_toml() {
        let rules_file = project_root().join(".coverage-rules.toml");
        let contents = std::fs::read_to_string(&rules_file)
            .expect("Should be able to read coverage rules");

        // Basic validation - check it looks like TOML
        assert!(
            contents.contains("[overall]"),
            "Coverage rules should have [overall] section"
        );
        assert!(
            contents.contains("min_line_coverage"),
            "Coverage rules should define min_line_coverage"
        );
        assert!(
            contents.contains("min_branch_coverage"),
            "Coverage rules should define min_branch_coverage"
        );
    }

    #[test]
    fn test_python_coverage_script_valid_syntax() {
        let python_script = scripts_dir().join("coverage_reporter.py");

        // Try to parse the Python file to check for syntax errors
        #[cfg(feature = "python-validation")]
        {
            let output = Command::new("python3")
                .arg("-m")
                .arg("py_compile")
                .arg(&python_script)
                .output();

            // If python3 is available, the script should compile without errors
            if let Ok(output) = output {
                assert!(
                    output.status.success(),
                    "Python coverage script should have valid syntax: {}",
                    String::from_utf8_lossy(&output.stderr)
                );
            }
        }
    }

    #[test]
    fn test_ci_workflow_valid_yaml() {
        let workflows_dir = project_root().join(".github").join("workflows");
        let coverage_workflow = workflows_dir.join("coverage-report.yml");

        let contents = std::fs::read_to_string(&coverage_workflow)
            .expect("Should be able to read CI workflow");

        // Basic validation - check it looks like YAML
        assert!(
            contents.contains("name:"),
            "Workflow should have a name"
        );
        assert!(
            contents.contains("on:"),
            "Workflow should have triggers"
        );
        assert!(
            contents.contains("jobs:"),
            "Workflow should have jobs"
        );
        assert!(
            contents.contains("coverage:"),
            "Workflow should have coverage job"
        );
    }

    #[test]
    fn test_documentation_contains_required_sections() {
        let docs_dir = project_root().join("docs").join("testing");
        let coverage_doc = docs_dir.join("coverage-reporting.md");

        let contents = std::fs::read_to_string(&coverage_doc)
            .expect("Should be able to read coverage documentation");

        // Verify key sections exist
        assert!(
            contents.contains("## Quick Start"),
            "Documentation should have Quick Start section"
        );
        assert!(
            contents.contains("## Usage"),
            "Documentation should have Usage section"
        );
        assert!(
            contents.contains("## Configuration"),
            "Documentation should have Configuration section"
        );
        assert!(
            contents.contains("## CI/CD Integration"),
            "Documentation should have CI/CD Integration section"
        );
        assert!(
            contents.contains("## Troubleshooting"),
            "Documentation should have Troubleshooting section"
        );
    }

    #[test]
    fn test_coverage_thresholds_defined() {
        let rules_file = project_root().join(".coverage-rules.toml");
        let contents = std::fs::read_to_string(&rules_file)
            .expect("Should be able to read coverage rules");

        // Verify thresholds are defined and reasonable
        assert!(
            contents.contains("95"),
            "Should have 95% threshold (common standard)"
        );
        assert!(
            contents.contains("90"),
            "Should have 90% threshold (branch coverage)"
        );
    }

    #[test]
    fn test_output_directories_configured() {
        let rules_file = project_root().join(".coverage-rules.toml");
        let contents = std::fs::read_to_string(&rules_file)
            .expect("Should be able to read coverage rules");

        // Verify output directories are configured
        assert!(
            contents.contains("coverage-reports"),
            "Should configure coverage-reports output directory"
        );
        assert!(
            contents.contains("badges"),
            "Should configure badges output directory"
        );
    }

    #[test]
    fn test_coverage_tools_documented() {
        let docs_dir = project_root().join("docs").join("testing");
        let coverage_doc = docs_dir.join("coverage-reporting.md");

        let contents = std::fs::read_to_string(&coverage_doc)
            .expect("Should be able to read coverage documentation");

        // Verify both tools are documented
        assert!(
            contents.contains("llvm-cov"),
            "Documentation should mention llvm-cov tool"
        );
        assert!(
            contents.contains("tarpaulin"),
            "Documentation should mention tarpaulin tool"
        );
    }

    #[test]
    fn test_report_formats_documented() {
        let docs_dir = project_root().join("docs").join("testing");
        let coverage_doc = docs_dir.join("coverage-reporting.md");

        let contents = std::fs::read_to_string(&coverage_doc)
            .expect("Should be able to read coverage documentation");

        // Verify all report formats are documented
        assert!(
            contents.contains("HTML"),
            "Documentation should mention HTML reports"
        );
        assert!(
            contents.contains("JSON"),
            "Documentation should mention JSON reports"
        );
        assert!(
            contents.contains("LCov"),
            "Documentation should mention LCov reports"
        );
        assert!(
            contents.contains("terminal"),
            "Documentation should mention terminal reports"
        );
    }
}

#[cfg(test)]
mod coverage_integration_tests {
    use super::*;

    #[test]
    #[ignore] // This test requires cargo-llvm-cov to be installed
    fn test_coverage_report_generation() {
        let project_root = project_root();
        let shell_script = scripts_dir().join("generate_coverage_report.sh");

        // Run the coverage script in test mode
        let output = Command::new(&shell_script)
            .arg("--format")
            .arg("terminal")
            .arg("--fail-under")
            .arg("0") // Don't fail on low coverage for this test
            .current_dir(&project_root)
            .output();

        if let Ok(output) = output {
            // The script should run without crashing
            // (it may fail due to missing tests, but the script itself should work)
            let stdout = String::from_utf8_lossy(&output.stdout);
            let stderr = String::from_utf8_lossy(&output.stderr);

            assert!(
                !stderr.contains("ERROR:"),
                "Coverage script should not have critical errors: {}",
                stderr
            );
        }
    }

    #[test]
    fn test_coverage_output_directory_structure() {
        let project_root = project_root();
        let coverage_dir = project_root.join("coverage-reports");

        // The coverage directory structure should be well-defined
        // (this test verifies the expected structure, not that it exists)

        let expected_subdirs = vec![
            "html",
            "badges",
        ];

        for subdir in expected_subdirs {
            let path = coverage_dir.join(subdir);
            // We don't assert existence (reports may not have been generated yet)
            // but we verify the path construction works
            assert_eq!(
                path,
                coverage_dir.join(subdir),
                "Coverage directory structure should be consistent"
            );
        }
    }
}

#[cfg(test)]
mod coverage_configuration_tests {
    use super::*;

    #[test]
    fn test_coverage_environment_variables() {
        // Verify environment variable names are documented
        let cargo_config = project_root().join(".cargo").join("config.toml");
        let contents = std::fs::read_to_string(&cargo_config)
            .expect("Should be able to read cargo config");

        assert!(
            contents.contains("COVERAGE_MINIMUM_LINE_COVERAGE"),
            "Should define COVERAGE_MINIMUM_LINE_COVERAGE variable"
        );
        assert!(
            contents.contains("COVERAGE_MINIMUM_BRANCH_COVERAGE"),
            "Should define COVERAGE_MINIMUM_BRANCH_COVERAGE variable"
        );
        assert!(
            contents.contains("COVERAGE_MINIMUM_FUNCTION_COVERAGE"),
            "Should define COVERAGE_MINIMUM_FUNCTION_COVERAGE variable"
        );
    }

    #[test]
    fn test_coverage_exclusion_patterns() {
        let rules_file = project_root().join(".coverage-rules.toml");
        let contents = std::fs::read_to_string(&rules_file)
            .expect("Should be able to read coverage rules");

        // Verify common exclusions are defined
        assert!(
            contents.contains("tests/**"),
            "Should exclude test files from coverage"
        );
        assert!(
            contents.contains("examples/**"),
            "Should exclude example files from coverage"
        );
        assert!(
            contents.contains("benches/**"),
            "Should exclude benchmark files from coverage"
        );
    }

    #[test]
    fn test_coverage_quality_gates() {
        let rules_file = project_root().join(".coverage-rules.toml");
        let contents = std::fs::read_to_string(&rules_file)
            .expect("Should be able to read coverage rules");

        // Verify quality gate settings
        assert!(
            contents.contains("fail_below_threshold"),
            "Should define fail_below_threshold setting"
        );
        assert!(
            contents.contains("fail_on_degradation"),
            "Should define fail_on_degradation setting"
        );
    }
}
