use serde::{Deserialize, Serialize};

#[derive(Debug, Default, Clone, Deserialize, Serialize)]
pub struct LyxalismCapabilities {
	#[serde(default)]
	pub allow_scripting: bool,
	#[serde(default)]
	pub allow_arbitrary_queries: bool,
	#[serde(default)]
	pub allow_functions: Vec<String>,
	#[serde(default)]
	pub allow_net: Vec<String>,
}
