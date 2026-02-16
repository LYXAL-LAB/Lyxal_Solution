use anyhow::{anyhow, Context, Result};
use cargo_metadata::{MetadataCommand};
use std::collections::HashMap;
use std::fs;
use std::path::Path;
use std::path::PathBuf;

#[derive(Debug, serde::Serialize, serde::Deserialize)]
struct BundleSizeEntry {
    name: String,
    path: String,
    size_bytes: u64,
    size_human: String,
    timestamp: i64,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
struct BundleComparison {
    name: String,
    baseline_size: u64,
    current_size: u64,
    delta_bytes: i64,
    delta_percent: f64,
    status: String,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
struct BundleSizeReport {
    timestamp: i64,
    branch: String,
    commit: String,
    bundles: Vec<BundleSizeEntry>,
    comparisons: Vec<BundleComparison>,
    summary: ReportSummary,
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
struct ReportSummary {
    total_bundles: usize,
    total_size: u64,
    baseline_total: u64,
    total_delta_bytes: i64,
    total_delta_percent: f64,
    passed: bool,
    threshold_percent: f64,
}

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().collect();
    let mode = args.get(1).map(|s| s.as_str()).unwrap_or("check");

    let threshold_percent = args
        .get(2)
        .and_then(|s| s.parse::<f64>().ok())
        .unwrap_or(5.0);

    let baseline_path = args.get(3).cloned().unwrap_or_else(|| {
        dirs::home_dir()
            .map(|p| p.join(".bundle-size-baseline.json"))
            .and_then(|p| p.to_str().map(|s| s.to_string()))
            .unwrap_or(".bundle-size-baseline.json".to_string())
    });

    let output_path = args
        .get(4)
        .cloned()
        .unwrap_or_else(|| "bundle-size-report.json".to_string());

    match mode {
        "check" => run_bundle_size_check(threshold_percent, &baseline_path, &output_path),
        "baseline" => create_baseline(&baseline_path),
        "analyze" => analyze_bundles(&output_path),
        _ => {
            eprintln!("Usage:");
            eprintln!("  bundle-size-monitor check [threshold] [baseline_file] [output_file]");
            eprintln!("  bundle-size-monitor baseline [baseline_file]");
            eprintln!("  bundle-size-monitor analyze [output_file]");
            eprintln!("\nExamples:");
            eprintln!("  bundle-size-monitor check 5.0 .bundle-size-baseline.json bundle-size-report.json");
            eprintln!("  bundle-size-monitor baseline .bundle-size-baseline.json");
            eprintln!("  bundle-size-monitor analyze bundle-size-report.json");
            Ok(())
        }
    }
}

fn run_bundle_size_check(threshold: f64, baseline_path: &str, output_path: &str) -> Result<()> {
    println!("=== Bundle Size Monitor ===");
    println!("Threshold: {}%", threshold);
    println!("Baseline: {}", baseline_path);
    println!("Output: {}", output_path);
    println!();

    let current = get_current_sizes()?;
    let baseline = load_baseline(baseline_path);

    let comparisons = compare_bundles(&current, baseline)?;
    let summary = generate_summary(&current, &comparisons, threshold);

    let report = BundleSizeReport {
        timestamp: chrono::Utc::now().timestamp(),
        branch: get_current_branch(),
        commit: get_current_commit()?,
        bundles: current,
        comparisons,
        summary: summary.clone(),
    };

    fs::write(output_path, serde_json::to_string_pretty(&report)?)
        .context("Failed to write report")?;

    print_report(&report);

    if !summary.passed {
        anyhow::bail!("Bundle size increase exceeds threshold of {}%", threshold);
    }

    Ok(())
}

fn create_baseline(baseline_path: &str) -> Result<()> {
    println!("=== Creating Baseline ===");
    println!("Baseline file: {}", baseline_path);
    println!();

    let bundles = get_current_sizes()?;
    let baseline = BundleSizeReport {
        timestamp: chrono::Utc::now().timestamp(),
        branch: get_current_branch(),
        commit: get_current_commit()?,
        bundles,
        comparisons: vec![],
        summary: ReportSummary {
            total_bundles: 0,
            total_size: 0,
            baseline_total: 0,
            total_delta_bytes: 0,
            total_delta_percent: 0.0,
            passed: true,
            threshold_percent: 5.0,
        },
    };

    fs::write(baseline_path, serde_json::to_string_pretty(&baseline)?)
        .context("Failed to write baseline")?;

    println!("Baseline created successfully with {} bundles", baseline.bundles.len());

    for bundle in &baseline.bundles {
        println!("  - {}: {}", bundle.name, bundle.size_human);
    }

    Ok(())
}

fn analyze_bundles(output_path: &str) -> Result<()> {
    println!("=== Analyzing Bundles ===");

    let bundles = get_current_sizes()?;

    let total_size: u64 = bundles.iter().map(|b| b.size_bytes).sum();

    println!("Total bundles: {}", bundles.len());
    println!("Total size: {}", format_size(total_size));
    println!();

    println!("Bundle breakdown:");
    for bundle in &bundles {
        let percent = if total_size > 0 {
            (bundle.size_bytes as f64 / total_size as f64) * 100.0
        } else {
            0.0
        };
        println!("  {} - {} ({:.1}%)", bundle.name, bundle.size_human, percent);
    }

    let report = BundleSizeReport {
        timestamp: chrono::Utc::now().timestamp(),
        branch: get_current_branch(),
        commit: get_current_commit()?,
        bundles,
        comparisons: vec![],
        summary: ReportSummary {
            total_bundles: bundles.len(),
            total_size,
            baseline_total: 0,
            total_delta_bytes: 0,
            total_delta_percent: 0.0,
            passed: true,
            threshold_percent: 5.0,
        },
    };

    fs::write(output_path, serde_json::to_string_pretty(&report)?)
        .context("Failed to write analysis")?;

    println!();
    println!("Analysis report saved to: {}", output_path);

    Ok(())
}

fn get_current_sizes() -> Result<Vec<BundleSizeEntry>> {
    let metadata = MetadataCommand::new()
        .no_deps()
        .exec()
        .context("Failed to get cargo metadata")?;

    let target_dir = metadata.target_directory;
    let wasm_target = target_dir.join("wasm32-unknown-unknown").join("release");

    let mut bundles = Vec::new();

    if !wasm_target.exists() {
        return Err(anyhow!(
            "WASM target directory not found at {:?}. Please build with `cargo build --target wasm32-unknown-unknown --release`",
            wasm_target
        ));
    }

    let wasm_files = find_wasm_files(&wasm_target)?;

    if wasm_files.is_empty() {
        return Err(anyhow!(
            "No WASM files found in {}. Please build your WASM packages first.",
            wasm_target.display()
        ));
    }

    for wasm_path in wasm_files {
        let size = fs::metadata(&wasm_path)
            .with_context(|| format!("Failed to get metadata for {:?}", wasm_path))?
            .len();

        let name = wasm_path
            .file_stem()
            .and_then(|s| s.to_str())
            .unwrap_or("unknown")
            .to_string();

        bundles.push(BundleSizeEntry {
            name,
            path: wasm_path
                .strip_prefix(&target_dir)
                .unwrap_or(&wasm_path)
                .to_string_lossy()
                .to_string(),
            size_bytes: size,
            size_human: format_size(size),
            timestamp: chrono::Utc::now().timestamp(),
        });
    }

    bundles.sort_by(|a, b| a.name.cmp(&b.name));

    Ok(bundles)
}

fn find_wasm_files(dir: &Path) -> Result<Vec<PathBuf>> {
    let mut wasm_files = Vec::new();

    let entries = fs::read_dir(dir)
        .with_context(|| format!("Failed to read directory: {}", dir.display()))?;

    for entry in entries {
        let entry = entry?;
        let path = entry.path();

        if path.is_dir() {
            wasm_files.extend(find_wasm_files(&path)?);
        } else if path.extension().and_then(|s| s.to_str()) == Some("wasm") {
            wasm_files.push(path);
        }
    }

    Ok(wasm_files)
}

fn load_baseline(path: &str) -> Option<BundleSizeReport> {
    fs::read_to_string(path)
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
}

fn compare_bundles(
    current: &[BundleSizeEntry],
    baseline: Option<BundleSizeReport>,
) -> Result<Vec<BundleComparison>> {
    let baseline_bundles: HashMap<String, u64> = match baseline {
        Some(b) => {
            let mut map = HashMap::new();
            for bundle in b.bundles {
                map.insert(bundle.name, bundle.size_bytes);
            }
            map
        }
        None => HashMap::new(),
    };

    let mut comparisons = Vec::new();

    for current_bundle in current {
        let baseline_size = baseline_bundles.get(&current_bundle.name).copied().unwrap_or(0);
        let delta_bytes = current_bundle.size_bytes as i64 - baseline_size as i64;

        let delta_percent = if baseline_size > 0 {
            ((delta_bytes as f64 / baseline_size as f64) * 100.0)
        } else {
            0.0
        };

        let status = if baseline_size == 0 {
            "NEW".to_string()
        } else if delta_bytes > 0 {
            "INCREASED".to_string()
        } else if delta_bytes < 0 {
            "DECREASED".to_string()
        } else {
            "UNCHANGED".to_string()
        };

        comparisons.push(BundleComparison {
            name: current_bundle.name.clone(),
            baseline_size,
            current_size: current_bundle.size_bytes,
            delta_bytes,
            delta_percent,
            status,
        });
    }

    comparisons.sort_by(|a, b| b.delta_percent.partial_cmp(&a.delta_percent).unwrap());

    Ok(comparisons)
}

fn generate_summary(
    current: &[BundleSizeEntry],
    comparisons: &[BundleComparison],
    threshold: f64,
) -> ReportSummary {
    let total_size: u64 = current.iter().map(|b| b.size_bytes).sum();
    let baseline_total: u64 = comparisons.iter().map(|c| c.baseline_size).sum();

    let total_delta_bytes: i64 = comparisons.iter().map(|c| c.delta_bytes).sum();

    let total_delta_percent = if baseline_total > 0 {
        (total_delta_bytes as f64 / baseline_total as f64) * 100.0
    } else {
        0.0
    };

    let passed = total_delta_percent <= threshold;

    ReportSummary {
        total_bundles: current.len(),
        total_size,
        baseline_total,
        total_delta_bytes,
        total_delta_percent,
        passed,
        threshold_percent: threshold,
    }
}

fn print_report(report: BundleSizeReport) {
    println!("=== Bundle Size Report ===");
    println!("Branch: {}", report.branch);
    println!("Commit: {}", commit_short(&report.commit));
    println!("Timestamp: {}", timestamp_to_date(report.timestamp));
    println!();

    println!("--- Summary ---");
    println!("Total bundles: {}", report.summary.total_bundles);
    println!("Total size: {}", format_size(report.summary.total_size));

    if report.summary.baseline_total > 0 {
        println!(
            "Baseline total: {}",
            format_size(report.summary.baseline_total)
        );
        println!(
            "Delta: {} ({}%)",
            format_delta(report.summary.total_delta_bytes),
            report.summary.total_delta_percent
        );
        println!("Status: {}", if report.summary.passed { "PASS" } else { "FAIL" });
    }

    println!();

    if !report.comparisons.is_empty() {
        println!("--- Bundle Changes ---");
        let table = format_comparison_table(&report.comparisons);
        println!("{}", table);
    }

    println!("--- All Bundles ---");
    for bundle in &report.bundles {
        println!("  {} - {}", bundle.name, bundle.size_human);
    }
}

fn format_comparison_table(comparisons: &[BundleComparison]) -> String {
    let mut table = String::new();

    table.push_str("Bundle");
    table.push_str("\t");
    table.push_str("Baseline");
    table.push_str("\t");
    table.push_str("Current");
    table.push_str("\t");
    table.push_str("Delta");
    table.push_str("\t");
    table.push_str("Change");
    table.push_str("\t");
    table.push_str("Status");
    table.push_str("\n");

    for comp in comparisons {
        table.push_str(&comp.name);
        table.push_str("\t");
        table.push_str(&format_size(comp.baseline_size));
        table.push_str("\t");
        table.push_str(&format_size(comp.current_size));
        table.push_str("\t");
        table.push_str(&format_delta(comp.delta_bytes));
        table.push_str("\t");
        table.push_str(&format!("{:.1}%", comp.delta_percent));
        table.push_str("\t");
        table.push_str(&comp.status);
        table.push_str("\n");
    }

    table
}

fn format_size(bytes: u64) -> String {
    if bytes >= 1024 * 1024 {
        format!("{:.2} MiB", bytes as f64 / (1024.0 * 1024.0))
    } else if bytes >= 1024 {
        format!("{:.2} KiB", bytes as f64 / 1024.0)
    } else {
        format!("{} B", bytes)
    }
}

fn format_delta(bytes: i64) -> String {
    let abs = bytes.abs() as u64;
    let formatted = if abs >= 1024 * 1024 {
        format!("{:.2} MiB", abs as f64 / (1024.0 * 1024.0))
    } else if abs >= 1024 {
        format!("{:.2} KiB", abs as f64 / 1024.0)
    } else {
        format!("{} B", abs)
    };

    if bytes >= 0 {
        format!("+{}", formatted)
    } else {
        format!("-{}", formatted)
    }
}

fn timestamp_to_date(timestamp: i64) -> String {
    let dt = chrono::DateTime::<chrono::Utc>::from_timestamp(timestamp, 0);
    dt.map(|d| d.format("%Y-%m-%d %H:%M:%S UTC").to_string())
        .unwrap_or_else(|| "Invalid timestamp".to_string())
}

fn commit_short(commit: &str) -> String {
    commit.chars().take(8).collect()
}

fn get_current_branch() -> String {
    std::process::Command::new("git")
        .args(["rev-parse", "--abbrev-ref", "HEAD"])
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .unwrap_or_else(|| "unknown".to_string())
}

fn get_current_commit() -> Result<String> {
    let output = std::process::Command::new("git")
        .args(["rev-parse", "HEAD"])
        .output()
        .context("Failed to get commit - is this a git repository?")?;

    if output.status.success() {
        Ok(String::from_utf8(output.stdout)
            .context("Commit hash is not valid UTF-8")?
            .trim()
            .to_string())
    } else {
        Err(anyhow!("git rev-parse failed"))
    }
}
