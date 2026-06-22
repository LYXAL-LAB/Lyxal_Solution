use anyhow::Result;
use semver::Version;
use serde::{Deserialize, Serialize};
use lyxalism_types::err::PrefixError;

use crate::capabilities::LyxalismCapabilities;

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct LyxalismConfig {
	#[serde(rename = "package")]
	pub meta: LyxalismMeta,
	#[serde(default)]
	pub capabilities: LyxalismCapabilities,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct LyxalismMeta {
	pub organisation: String,
	pub name: String,
	pub version: Version,
}

impl LyxalismConfig {
	pub fn parse(s: &str) -> Result<Self> {
		toml::from_str(s).prefix_err(|| "Failed to parse Lyxalism config")
	}

	pub fn to_string(&self) -> Result<String> {
		toml::to_string(self).prefix_err(|| "Failed to serialize Lyxalism config")
	}

	pub fn file_name(&self) -> String {
		format!("{}-{}-{}.surli", self.meta.organisation, self.meta.name, self.meta.version)
	}
}
