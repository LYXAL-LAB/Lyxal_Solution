use crate::error::{NetError, Result};
use ed25519_dalek::{Signer, SigningKey, VerifyingKey};
use hkdf::Hkdf;
use hmac::{Hmac, Mac};
use rand::rngs::OsRng;
use sha2::Sha256;
use std::fs;
use std::path::Path;
use x25519_dalek::{EphemeralSecret, PublicKey as XPublicKey};

#[derive(Clone)]
pub struct NodeIdentity {
	pub keypair: SigningKey,
}

impl NodeIdentity {
	pub fn generate() -> Self {
		let mut csprng = OsRng;
		let keypair = SigningKey::generate(&mut csprng);
		Self {
			keypair,
		}
	}

	pub fn load_or_create<P: AsRef<Path>>(path: P) -> Result<Self> {
		let path = path.as_ref();
		if path.exists() {
			let bytes = fs::read(path)?;
			if bytes.len() != 32 {
				return Err(NetError::Protocol("Invalid key file length".into()));
			}
			let keypair = SigningKey::from_bytes(bytes.as_slice().try_into().unwrap());
			Ok(Self {
				keypair,
			})
		} else {
			let identity = Self::generate();
			fs::write(path, identity.keypair.to_bytes())?;
			Ok(identity)
		}
	}

	pub fn public_key(&self) -> VerifyingKey {
		self.keypair.verifying_key()
	}

	pub fn public_bytes(&self) -> [u8; 32] {
		self.keypair.verifying_key().to_bytes()
	}

	pub fn sign(&self, message: &[u8]) -> [u8; 64] {
		self.keypair.sign(message).to_bytes()
	}
}

pub fn derive_node_id(pubkey: &VerifyingKey) -> u128 {
	let bytes = pubkey.to_bytes();
	let hash = blake3::hash(&bytes);
	let hash_bytes = hash.as_bytes();
	// Take first 16 bytes for u128
	let mut buf = [0u8; 16];
	buf.copy_from_slice(&hash_bytes[0..16]);
	u128::from_le_bytes(buf)
}

/// Gestion de la clé de session (Dérivée) avec support de rotation.
pub struct SessionCipher {
	secret: [u8; 32],
	previous_secret: Option<[u8; 32]>,
	created_at: std::time::Instant,
}

impl SessionCipher {
	/// Initialise la session avec le secret partagé (ECDH output) et le sel (Nonce).
	pub fn new(shared_secret: &[u8], salt: &[u8]) -> Self {
		let hkdf = Hkdf::<Sha256>::new(Some(salt), shared_secret);
		let mut okm = [0u8; 32];
		hkdf.expand(b"lyxal-lsp-session-v1", &mut okm).expect("HKDF expand failed");

		Self {
			secret: okm,
			previous_secret: None,
			created_at: std::time::Instant::now(),
		}
	}

	/// Effectue une rotation de la clé en utilisant un nouveau sel.
	/// L'ancienne clé est conservée comme `previous_secret` pour permettre une transition fluide.
	pub fn rotate(&mut self, shared_secret: &[u8], new_salt: &[u8]) {
		let hkdf = Hkdf::<Sha256>::new(Some(new_salt), shared_secret);
		let mut okm = [0u8; 32];
		hkdf.expand(b"lyxal-lsp-session-v1", &mut okm).expect("HKDF expand failed");

		self.previous_secret = Some(self.secret);
		self.secret = okm;
		self.created_at = std::time::Instant::now();
	}

	/// Retourne l'âge de la clé actuelle.
	pub fn age(&self) -> std::time::Duration {
		self.created_at.elapsed()
	}

	/// Génère un HMAC-SHA256 pour un payload donné.
	pub fn mac(&self, data: &[u8]) -> [u8; 32] {
		let mut mac = Hmac::<Sha256>::new_from_slice(&self.secret).expect("HMAC init failed");
		mac.update(data);
		mac.finalize().into_bytes().into()
	}

	/// Vérifie le tag HMAC en essayant la clé actuelle, puis la précédente si elle existe.
	pub fn verify(&self, data: &[u8], tag: &[u8; 32]) -> bool {
		// Essayer la clé actuelle
		let mut mac = Hmac::<Sha256>::new_from_slice(&self.secret).expect("HMAC init failed");
		mac.update(data);
		if mac.verify_slice(tag).is_ok() {
			return true;
		}

		// Essayer la clé précédente (utile pendant la fenêtre de rotation)
		if let Some(prev) = &self.previous_secret {
			let mut mac = Hmac::<Sha256>::new_from_slice(prev).expect("HMAC init failed");
			mac.update(data);
			return mac.verify_slice(tag).is_ok();
		}

		false
	}
}

pub fn generate_ephemeral() -> (EphemeralSecret, [u8; 32]) {
	let secret = EphemeralSecret::random_from_rng(OsRng);
	let public = XPublicKey::from(&secret);
	(secret, *public.as_bytes())
}
