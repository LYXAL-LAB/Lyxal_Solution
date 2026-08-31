//! CLI commands that read from a croniq SQLite database directly.

use std::path::Path;

use lyxal_store::{models::DeadLetterFilter, surreal::SurrealStore, traits::DeadLetterStore};
use miette::{IntoDiagnostic, Result, miette};
use uuid::Uuid;

// ─── dead-letters ─────────────────────────────────────────────────────────────

/// `croniq dead-letters` — list dead-lettered executions from the store.
pub fn dead_letters(_data_dir: &Path, job_key: Option<&str>, limit: u32) -> Result<()> {
    let surreal_endpoint = std::env::var("LYXAL_DB")
        .or_else(|_| std::env::var("SURREALDB_URL"))
        .unwrap_or_else(|_| "127.0.0.1:8000".to_string());
    let surreal_ns = std::env::var("SURREALDB_NS").unwrap_or_else(|_| "main".to_string());
    let surreal_db = std::env::var("SURREALDB_DB").unwrap_or_else(|_| "main".to_string());
    let surreal_user = std::env::var("SURREALDB_USER").unwrap_or_else(|_| "root".to_string());
    let surreal_pass = std::env::var("SURREALDB_PASS").unwrap_or_else(|_| "root".to_string());

    let store = SurrealStore::connect_sync(
        &surreal_endpoint,
        &surreal_ns,
        &surreal_db,
        &surreal_user,
        &surreal_pass,
    )
    .map_err(|e| miette!("Failed to connect to SurrealDB: {e}"))?;

    let filter = DeadLetterFilter {
        job_key: job_key.map(str::to_string),
        limit: Some(limit),
    };

    let letters = store.list_dead_letters(&filter).into_diagnostic()?;

    if letters.is_empty() {
        if let Some(key) = job_key {
            println!("No dead letters for job '{key}'.");
        } else {
            println!("Dead letter queue is empty.");
        }
        return Ok(());
    }

    println!(
        "{:<38} {:<32} {:>7} ERROR",
        "DEAD LETTER ID", "JOB KEY", "ATTEMPT"
    );
    println!("{}", "-".repeat(100));

    for dl in &letters {
        let error_preview: String = dl.error.chars().take(40).collect();
        let error_display = if dl.error.len() > 40 {
            format!("{error_preview}…")
        } else {
            error_preview
        };
        println!(
            "{:<38} {:<32} {:>7} {}",
            dl.id, dl.job_key, dl.attempt, error_display
        );
    }

    println!();
    println!("Total: {} dead letter(s)", letters.len());

    if let Some(first) = letters.first() {
        println!(
            "\nRun `croniq dead-letters-inspect {} --data-dir <path>` for full details.",
            first.id
        );
    }

    Ok(())
}

/// `croniq dead-letters-inspect <id>` — show full details of a dead letter.
pub fn dead_letters_inspect(_data_dir: &Path, id: &str) -> Result<()> {
    let surreal_endpoint = std::env::var("LYXAL_DB")
        .or_else(|_| std::env::var("SURREALDB_URL"))
        .unwrap_or_else(|_| "127.0.0.1:8000".to_string());
    let surreal_ns = std::env::var("SURREALDB_NS").unwrap_or_else(|_| "main".to_string());
    let surreal_db = std::env::var("SURREALDB_DB").unwrap_or_else(|_| "main".to_string());
    let surreal_user = std::env::var("SURREALDB_USER").unwrap_or_else(|_| "root".to_string());
    let surreal_pass = std::env::var("SURREALDB_PASS").unwrap_or_else(|_| "root".to_string());

    let store = SurrealStore::connect_sync(
        &surreal_endpoint,
        &surreal_ns,
        &surreal_db,
        &surreal_user,
        &surreal_pass,
    )
    .map_err(|e| miette!("Failed to connect to SurrealDB: {e}"))?;

    let uuid = Uuid::parse_str(id).map_err(|e| miette!("Invalid UUID '{id}': {e}"))?;

    let dl = store
        .get_dead_letter(uuid)
        .into_diagnostic()?
        .ok_or_else(|| miette!("Dead letter '{id}' not found."))?;

    println!("Dead Letter Details");
    println!("{}", "=".repeat(60));
    println!("ID:            {}", dl.id);
    println!("Execution ID:  {}", dl.execution_id);
    println!("Job Key:       {}", dl.job_key);
    println!("Fire At:       {}", dl.fire_at);
    println!("Attempt:       {}", dl.attempt);
    println!("Dead Reason:   {}", dl.dead_reason);
    println!("Created At:    {}", dl.created_at);
    if let Some(expires) = dl.expires_at {
        println!("Expires At:    {}", expires);
    }
    println!();
    println!("Error:");
    println!("{}", dl.error);

    if !dl.metadata.is_empty() {
        println!();
        println!("Metadata:");
        for (k, v) in &dl.metadata {
            println!("  {k}: {v}");
        }
    }

    Ok(())
}
