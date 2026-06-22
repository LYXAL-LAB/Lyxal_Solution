use std::path::PathBuf;

use anyhow::Result;
use lyxal_types::ToSql;
use lyxalism_runtime::controller::Runtime;
use lyxalism_runtime::package::LyxalismPackage;
use lyxalism_types::err::PrefixError;

use crate::cli::module::host::DemoHost;

pub async fn init(
	file: PathBuf,
	fnc: Option<String>,
	args: Vec<lyxal_types::Value>,
) -> Result<()> {
	let package = LyxalismPackage::from_file(file)?;

	// Load the WASM module
	let runtime = Runtime::new(package)?;
	let host = Box::new(DemoHost::new());
	let mut controller =
		runtime.new_controller(host).await.prefix_err(|| "Failed to load WASM module")?;

	controller.init().await?;

	// Invoke the function with the provided arguments
	let result = controller.invoke(fnc, args).await;

	match result {
		Ok(result) => {
			println!("✅ {:#}", result.to_sql());
			Ok(())
		}
		Err(e) => {
			eprintln!("❌ {}", e);
			Err(e)
		}
	}
}
