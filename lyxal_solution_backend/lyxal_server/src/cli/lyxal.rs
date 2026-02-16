use anyhow::Result;
use crate::base64::{engine::general_purpose::STANDARD as BASE64, Engine as _};
use clap::Subcommand;
use crate::lyxal_net::identity::NodeIdentity;
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Subcommand)]
pub enum LyxalCommand {
	/// Manage node identity (keypair)
	Identity {
		#[command(subcommand)]
		command: IdentitySubcommands,
	},
	/// Manage trusted peers
	Trust {
		#[command(subcommand)]
		command: TrustSubcommands,
	},
}

#[derive(Subcommand, Debug)]
pub enum IdentitySubcommands {
	/// Show current node identity and public key
	Show {
		#[arg(long, help = "Path to identity file", default_value = "node.key")]
		path: PathBuf,
	},
	/// Generate a new identity (Warning: overwrites existing!)
	Generate {
		#[arg(long, help = "Path to identity file", default_value = "node.key")]
		path: PathBuf,
		#[arg(long, help = "Force overwrite if file exists")]
		force: bool,
	},
}

#[derive(Subcommand, Debug)]
pub enum TrustSubcommands {
	/// Add a peer to trusted_peers.toml
	Add {
		#[arg(help = "Node ID (Hex)")]
		node_id: String,
		#[arg(help = "Public Key (Base64)")]
		pubkey: String,
		#[arg(
			long,
			help = "Path to trusted_peers.toml",
			default_value = "config/trusted_peers.toml"
		)]
		output: PathBuf,
	},
	/// List trusted peers
	List {
		#[arg(
			long,
			help = "Path to trusted_peers.toml",
			default_value = "config/trusted_peers.toml"
		)]
		path: PathBuf,
	},
}

pub async fn init(args: LyxalCommand) -> Result<()> {
	match args {
		LyxalCommand::Identity {
			command,
		} => match command {
			IdentitySubcommands::Show {
				path,
			} => {
				let id = NodeIdentity::load_or_generate(&path)?;
				println!("Node ID: {:032x}", id.node_id);
				println!(
					"Public Key (Base64): {}",
					BASE64.encode(id.keypair.verifying_key().as_bytes())
				);
			}
			IdentitySubcommands::Generate {
				path,
				force,
			} => {
				if path.exists() && !force {
					anyhow::bail!(
						"Identity file already exists at {:?}. Use --force to overwrite.",
						path
					);
				}
				let id = NodeIdentity::load_or_generate(&path)?;
				println!("Generated New Identity:");
				println!("Node ID: {:032x}", id.node_id);
				println!(
					"Public Key (Base64): {}",
					BASE64.encode(id.keypair.verifying_key().as_bytes())
				);
			}
		},
		LyxalCommand::Trust {
			command,
		} => match command {
			TrustSubcommands::Add {
				node_id,
				pubkey,
				output,
			} => {
				// Ensure directory exists
				if let Some(parent) = output.parent() {
					fs::create_dir_all(parent)?;
				}

				let mut content = if output.exists() {
					fs::read_to_string(&output)?
				} else {
					"[peers]\n".to_string()
				};

				// Append peer (naive implementation for now, should use a TOML parser for production)
				let entry = format!("\"{}\" = \"{}\"\n", node_id.trim_start_matches("0x"), pubkey);
				content.push_str(&entry);

				fs::write(&output, content)?;
				println!("Added peer {} to {:?}", node_id, output);
			}
			TrustSubcommands::List {
				path,
			} => {
				if !path.exists() {
					println!("Trust store not found at {:?}", path);
				} else {
					let content = fs::read_to_string(&path)?;
					println!("--- Trusted Peers ({:?}) ---", path);
					println!("{}", content);
				}
			}
		},
	}
	Ok(())
}
