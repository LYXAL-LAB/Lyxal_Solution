use ed25519_dalek::{SigningKey, VerifyingKey, Signer};
use rand::rngs::OsRng;
use std::fs::{self, File};
use std::io::{self, Read, Write};
use std::path::Path;
use crate::error::{Result, NetError};
use tracing::{info, error};
use crate::crypto;

#[derive(Debug)]
pub struct NodeIdentity {
    pub keypair: SigningKey,
    pub node_id: u128,
}

impl NodeIdentity {
    /// Load identity from file or generate a new one if it doesn't exist.
    /// Strictly enforces 64-byte binary format.
    /// Fails fast if file exists but is corrupted.
    pub fn load_or_generate(path: &Path) -> Result<Self> {
        if path.exists() {
            Self::load(path)
        } else {
            Self::generate_and_save(path)
        }
    }

    fn load(path: &Path) -> Result<Self> {
        let mut file = File::open(path).map_err(|e| NetError::Io(e))?;
        let mut bytes = [0u8; 64];
        
        // Strict size check
        let metadata = file.metadata().map_err(|e| NetError::Io(e))?;
        if metadata.len() != 64 {
            error!("Identity file corrupted (wrong size): {:?}", path);
            return Err(NetError::CryptoError("Identity file corrupted".into()));
        }

        file.read_exact(&mut bytes).map_err(|e| NetError::Io(e))?;

        let keypair = SigningKey::from_keypair_bytes(&bytes).map_err(|_| NetError::CryptoError("Invalid keypair bytes".into()))?;
        let node_id = crypto::derive_node_id(&keypair.verifying_key());

        info!("Loaded Persistent Identity: {:032x}", node_id);
        Ok(Self { keypair, node_id })
    }

    fn generate_and_save(path: &Path) -> Result<Self> {
        info!("Generating new Persistent Identity...");
        let mut csprng = OsRng{};
        let keypair = SigningKey::generate(&mut csprng);
        let node_id = crypto::derive_node_id(&keypair.verifying_key());

        // Atomic write: write to .tmp, fsync, rename
        let tmp_path = path.with_extension("tmp");
        
        {
            let mut file = File::create(&tmp_path).map_err(|e| NetError::Io(e))?;
            
            // Set permissions 0600 on Unix
            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                let mut perms = file.metadata().map_err(|e| NetError::Io(e))?.permissions();
                perms.set_mode(0o600);
                file.set_permissions(perms).map_err(|e| NetError::Io(e))?;
            }
            // Windows: Best effort (default generic ACLs usually restricted to user on creation in user dirs)

            file.write_all(&keypair.to_keypair_bytes()).map_err(|e| NetError::Io(e))?;
            file.sync_all().map_err(|e| NetError::Io(e))?;
        }

        fs::rename(&tmp_path, path).map_err(|e| NetError::Io(e))?;
        
        // Fsync parent dir to ensure rename persistence (Unix best practice, optional but good)
        if let Some(parent) = path.parent() {
            if let Ok(dir) = File::open(parent) {
                let _ = dir.sync_all(); 
            }
        }

        info!("Saved new Identity to {:?} (NodeID: {:032x})", path, node_id);
        Ok(Self { keypair, node_id })
    }
    
    // Helper to sign data using the persistent key
    pub fn sign(&self, message: &[u8]) -> ed25519_dalek::Signature {
        self.keypair.sign(message)
    }
}

// Re-export utility for deriving ID from pubkey for TrustStore use
pub fn derive_node_id(pubkey: &VerifyingKey) -> u128 {
    crypto::derive_node_id(pubkey)
}
