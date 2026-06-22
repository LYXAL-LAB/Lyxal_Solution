use std::io::BufRead;

use anyhow::Result;
use async_trait::async_trait;
use lyxal_types::ToSql;
use lyxalism_runtime::config::LyxalismConfig;
use lyxalism_runtime::host::InvocationContext;
use lyxalism_runtime::kv::{BTreeMapStore, KVStore};

pub struct DemoHost {
	kv: BTreeMapStore,
}

impl DemoHost {
	pub fn new() -> Self {
		Self {
			kv: BTreeMapStore::new(),
		}
	}
}

/// Custom parser for `lyxal_types::Value`
fn parse_value(s: &str) -> Result<lyxal_types::Value, String> {
	lyxal_core::db::syn::value(s).map_err(|e| format!("Invalid value: {e}"))
}

#[async_trait]
impl InvocationContext for DemoHost {
	fn kv(&mut self) -> Result<&dyn KVStore> {
		Ok(&self.kv)
	}

	async fn sql(
		&mut self,
		_config: &LyxalismConfig,
		query: String,
		vars: lyxal_types::Object,
	) -> Result<lyxal_types::Value> {
		println!("The module is running a SQL query:");
		println!("SQL: {query}");
		println!("Vars: {}", vars.to_sql());
		println!("Please enter the result:");

		let stdin = std::io::stdin();
		loop {
			let line = match stdin.lock().lines().next() {
				Some(Ok(line)) => line,
				Some(Err(e)) => {
					anyhow::bail!("Failed to read from stdin: {e}");
				}
				None => {
					anyhow::bail!("stdin closed unexpectedly");
				}
			};

			match parse_value(&line) {
				Ok(x) => {
					println!(" ");
					return Ok(x);
				}
				Err(e) => {
					println!("Failed to parse value: {e}");
					println!("Please try again");
				}
			}
		}
	}

	async fn run(
		&mut self,
		_config: &LyxalismConfig,
		fnc: String,
		version: Option<String>,
		args: Vec<lyxal_types::Value>,
	) -> Result<lyxal_types::Value> {
		let version = version.map(|x| format!("<{x}>")).unwrap_or_default();
		println!("The module is running a function:");
		println!(
			" - {fnc}{version}({})",
			args.iter().map(|x| x.to_sql()).collect::<Vec<String>>().join(", ")
		);
		println!("\nPlease enter the result:");

		let stdin = std::io::stdin();
		loop {
			let line = match stdin.lock().lines().next() {
				Some(Ok(line)) => line,
				Some(Err(e)) => {
					anyhow::bail!("Failed to read from stdin: {e}");
				}
				None => {
					anyhow::bail!("stdin closed unexpectedly");
				}
			};

			match parse_value(&line) {
				Ok(x) => {
					println!(" ");
					return Ok(x);
				}
				Err(e) => {
					println!("Failed to parse value: {e}");
					println!("Please try again");
				}
			}
		}
	}

	fn stdout(&mut self, output: &str) -> Result<()> {
		println!("[surli::out] {}", output);
		Ok(())
	}

	fn stderr(&mut self, output: &str) -> Result<()> {
		eprintln!("[surli::err] {}", output);
		Ok(())
	}
}
