use anyhow::{Context, Result};
use clap::Parser;
use oxyde_cloud_deploy::{Cli, deploy_with_config_file};
use std::env;
use std::fs::write;
use std::path::PathBuf;
use std::process::exit;

#[tokio::main]
async fn main() -> Result<()> {
    let github_output_path =
        env::var("GITHUB_OUTPUT").context("Failed to get GITHUB_OUTPUT environment variable")?;

    let args: Vec<String> = env::args().collect();
    let error = &args[1];

    if !error.is_empty() {
        eprintln!("Error: {error}");
        write(github_output_path, format!("error={error}"))
            .context("Failed to write error to GitHub output file")?;
        exit(1);
    }

    let api_token = &args[2];
    let config_file = &args[3];
    let debug = &args[4];

    let leptos_args: Vec<String> = vec![
        "cargo".to_string(),
        "build".to_string(),
        "--release".to_string(),
    ];
    let leptos_args = Cli::parse_from(&leptos_args);

    let mut cargo_leptos_opts = leptos_args
        .opts()
        .context("Failed to parse cargo leptos options")?;

    if !debug.is_empty() {
        cargo_leptos_opts.verbose = 2;
    }

    unsafe {
        env::set_var("OXYDE_CLOUD_API_KEY", api_token);
    }

    deploy_with_config_file(&PathBuf::from(config_file), cargo_leptos_opts)
        .await
        .context("Failed to deploy with config file")
}
