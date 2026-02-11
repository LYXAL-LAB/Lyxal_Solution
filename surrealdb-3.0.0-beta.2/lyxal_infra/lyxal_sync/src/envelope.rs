use lyxal_revision::lyxal_revisioned;
use serde::{Deserialize, Serialize};

/// L'enveloppe de base transportant la donnée et les métadonnées d'audit.
/// Format de stockage interne.
#[lyxal_revisioned(lyxal_revision = 1)]
#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct LyxalEnvelope {
	pub magic: u32,       // 0x4C59584C
	pub timestamp: u64,   // Nanosecondes UTC
	pub node_id: u128,    // Producteur
	pub payload: Vec<u8>, // Donnée métier opaque
}

impl LyxalEnvelope {
	pub const MAGIC: u32 = 0x4C59584C;

	pub fn new(payload: Vec<u8>, node_id: u128, timestamp: u64) -> Self {
		Self {
			magic: Self::MAGIC,
			timestamp,
			node_id,
			payload,
		}
	}
}
