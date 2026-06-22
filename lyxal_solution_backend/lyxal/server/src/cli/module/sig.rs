use std::path::PathBuf;

use anyhow::Result;
use lyxalism_runtime::controller::Runtime;
use lyxalism_runtime::package::LyxalismPackage;
use lyxalism_types::err::PrefixError;

use crate::cli::module::host::DemoHost;

pub async fn init(file: PathBuf, fnc: Option<String>) -> Result<()> {
	let package =
		LyxalismPackage::from_file(file).prefix_err(|| "Failed to load Lyxalism package")?;

	// Load the WASM module from memory
	let runtime = Runtime::new(package)?;
	let host = Box::new(DemoHost::new());
	let mut controller =
		runtime.new_controller(host).await.prefix_err(|| "Failed to load WASM module")?;

	// Invoke the function with the provided arguments
	let args = controller.args(fnc.clone()).await.prefix_err(|| "Failed to collect arguments")?;
	let returns =
		controller.returns(fnc.clone()).await.prefix_err(|| "Failed to collect return type")?;

	println!(
		"\nSignature:\n - {}({}) -> {}",
		fnc.as_deref().unwrap_or("<default>"),
		args.iter().map(|arg| format!("{arg}")).collect::<Vec<_>>().join(", "),
		returns
	);

	Ok(())
}
