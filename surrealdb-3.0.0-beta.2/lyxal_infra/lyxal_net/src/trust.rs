use base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use ed25519_dalek::VerifyingKey;
use serde::Deserialize;
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};

use crate::error::{NetError, Result};
use tracing::{error, info, warn};

use crate::identity;

#[derive(Debug, PartialEq, Clone)]
pub enum TrustDecision {
	Allow,
	Deny(String),
}
#[derive(Debug, Deserialize)]
struct TrustConfig {
	peers: Option<HashMap<String, String>>, // "u128_hex" -> "base64_pubkey"
	realms: Option<HashMap<String, HashMap<String, String>>>, // RealmHex -> { NodeHex -> Key }
}

pub struct TrustStore {
	#[allow(dead_code)]
	path: PathBuf, // Added path
	trusted_keys: HashMap<u128, VerifyingKey>, // Changed PublicKey to VerifyingKey
	mode_tofu: bool,                           // Future flag
}

impl TrustStore {
	pub fn new(path: &Path, realm_id: u128) -> Result<Self> {
		let mut store = HashMap::new();

		if path.exists() {
			let content = fs::read_to_string(path).map_err(|e| NetError::Io(e))?;
			let config: TrustConfig = toml::from_str(&content).map_err(|e| {
				error!("FATAL: Failed to parse trusted_peers.toml at {:?}: {}", path, e);
				NetError::ConfigError(format!("Invalid trusted_peers.toml: {}", e))
			})?;

			// 1. Load Global Peers (optional fallback or base trust)
			if let Some(global_peers) = config.peers {
				for (id_hex, key_b64) in global_peers {
					Self::add_peer(&mut store, &id_hex, &key_b64)?;
				}
			}

			// 2. Load Realm-Specific Peers
			if let Some(realms) = config.realms {
				for (r_key, r_peers) in realms {
					let r_id_clean = r_key.trim_start_matches("0x");
					if let Ok(rid) = u128::from_str_radix(r_id_clean, 16) {
						if rid == realm_id {
							for (id_hex, key_b64) in r_peers {
								Self::add_peer(&mut store, &id_hex, &key_b64)?;
							}
						}
					}
				}
			}

			info!(
				"TrustStore: Loaded {} peers for Realm {:032x} from {:?}",
				store.len(),
				realm_id,
				path
			);
		} else {
			warn!(
				"TrustStore: Configuration file not found at {:?}. Using default security policy.",
				path
			);
		}

		let mode_tofu =
			std::env::var("LYXAL_TRUST_MODE").map(|v| v == "TOFU").unwrap_or_else(|_| {
				// Default to TOFU in Dev mode to facilitate local cluster setup
				let profile = std::env::var("LYXAL_PROFILE").unwrap_or_else(|_| "dev".into());
				let is_dev = profile.to_lowercase() == "dev";
				if !is_dev && std::env::var("LYXAL_TRUST_MODE").is_err() {
					warn!("SECURITY WARNING: Production profile detected but LYXAL_TRUST_MODE not set. Defaulting to STRICT mode (TOFU Disabled).");
					false
				} else {
					is_dev
				}
			});
		if mode_tofu {
			info!("TrustStore: TOFU Mode Enabled (Trust On First Use)");
		}

		Ok(Self {
			path: path.to_path_buf(), // Storing path
			trusted_keys: store,
			mode_tofu,
		})
	}

	fn add_peer(
		store: &mut HashMap<u128, VerifyingKey>,
		id_hex: &str,
		key_b64: &str,
	) -> Result<()> {
		// Parse NodeID (hex u128)
		let id_clean = id_hex.trim_start_matches("0x");
		let node_id = u128::from_str_radix(id_clean, 16)
			.map_err(|_| NetError::ConfigError(format!("Invalid NodeID hex: {}", id_hex)))?;

		// Parse PublicKey (base64)
		let key_bytes = BASE64.decode(key_b64).map_err(|_| {
			NetError::ConfigError(format!("Invalid Base64 key for NodeID {}", id_hex))
		})?;
		let pubkey = VerifyingKey::from_bytes(
			&key_bytes
				.try_into()
				.map_err(|_| NetError::ConfigError("Invalid Key Length".into()))?,
		)
		.map_err(|_| NetError::ConfigError("Invalid Ed25519 Key".into()))?;

		let derived = crate::identity::derive_node_id(&pubkey);
		if derived != node_id {
			error!("TrustStore SKIP: NodeID {} vs Derived {:032x}", id_hex, derived);
			return Ok(());
		}
		store.insert(node_id, pubkey);
		Ok(())
	}

	/// Check if a peer is trusted.
	/// Strict Mode: Must be in trust store.
	pub fn check(&self, node_id: u128, pubkey: &VerifyingKey) -> TrustDecision {
		// 1. Verify NodeID derivation (Basic Protocol Check)
		let derived_id = identity::derive_node_id(pubkey);
		if derived_id != node_id {
			warn!("SECURITY ALERT: NodeID mismatch. Asserted ID {:032x}, derived ID {:032x} from key.", node_id, derived_id);
			return TrustDecision::Deny("NodeID mismatch".into());
		}

		if self.trusted_keys.is_empty() && !self.mode_tofu {
			return TrustDecision::Deny("TrustStore Empty (Strict Mode)".into());
		}

		if let Some(trusted_key) = self.trusted_keys.get(&node_id) {
			if trusted_key.as_bytes() == pubkey.as_bytes() {
				TrustDecision::Allow
			} else {
				error!("SECURITY ALERT: KeyMismatch for known NodeID {:032x}. Possible MITM or rekeying without config update.", node_id);
				TrustDecision::Deny("Key Mismatch".into())
			}
		} else {
			if self.mode_tofu {
				info!("TrustStore: TOFU Allow for unknown Peer {:032x}", node_id);
				TrustDecision::Allow
			} else {
				warn!("TrustStore: Unknown Peer {:032x} rejected.", node_id);
				TrustDecision::Deny("Unknown Peer".into())
			}
		}
	}

	/// Returns the list of all trusted Node IDs.
	pub fn trusted_ids(&self) -> Vec<u128> {
		self.trusted_keys.keys().cloned().collect()
	}
}
