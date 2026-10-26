//! Adaptateurs de sources pour l'ingestion multiformat de Lyxal OS.
//!
//! Supporte :
//! - FAB-DIS 2.3 et 3.0 (standard BTP)
//! - CSV (RFC 4180 avec délimiteur dynamique)
//! - XML (BMEcat et catalogues hiérarchiques)
//! - JSON (JSON Array et NDJSON streaming)

pub mod csv;
pub mod fab_dis;
pub mod json;
pub mod xml;

pub use csv::CsvAdapter;
pub use fab_dis::FabDisAdapter;
pub use json::JsonAdapter;
pub use xml::XmlAdapter;

use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Arc;

use crate::error::IngestionError;
use crate::types::SourceFormat;

/// Enregistrement brut extrait d'une source avant normalisation.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct RawRecordDto {
    /// Numéro de ligne d'origine (1-indexé)
    pub line_number: usize,
    /// Référence brute fabricant/fournisseur
    pub raw_reference: String,
    /// Désignation ou libellé brut
    pub raw_designation: String,
    /// Code GTIN/EAN brut si présent
    pub raw_gtin: Option<String>,
    /// Fabricant brut si spécifié au niveau ligne
    pub raw_manufacturer: Option<String>,
    /// Marque commerciale brute
    pub raw_brand: Option<String>,
    /// Unité de mesure brute (ex: "PCE", "m2", "ML", "ROUL")
    pub raw_unit: Option<String>,
    /// Prix tarif indicatif brut
    pub raw_price: Option<f64>,
    /// Devise (ex: "EUR")
    pub raw_currency: Option<String>,
    /// Dimensions brutes
    pub raw_dimensions: Option<RawDimensionsDto>,
    /// Poids brut
    pub raw_weight: Option<RawWeightDto>,
    /// Attributs techniques bruts non structurés
    pub raw_attributes: HashMap<String, String>,
    /// Payload brut JSON intégral pour audit et traçabilité immuable
    pub raw_payload: serde_json::Value,
    /// Hachage BLAKE3 de la ligne brute
    pub raw_hash: String,
}

/// Dimensions brutes extraites d'une source.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Default)]
pub struct RawDimensionsDto {
    pub length: Option<f64>,
    pub width: Option<f64>,
    pub height: Option<f64>,
    pub unit: Option<String>,
}

/// Poids brut extrait d'une source.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Default)]
pub struct RawWeightDto {
    pub gross_weight: Option<f64>,
    pub net_weight: Option<f64>,
    pub unit: Option<String>,
}

/// Contrat universel d'un adaptateur de source d'ingestion.
#[async_trait]
pub trait SourceAdapter: Send + Sync {
    /// Format de source géré par l'adaptateur
    fn format(&self) -> SourceFormat;

    /// Versions du format supportées
    fn supported_versions(&self) -> &'static [&'static str];

    /// Valide la conformité de l'en-tête ou de l'échantillon initial
    fn validate_header(&self, sample: &[u8]) -> Result<(), IngestionError>;

    /// Parse le flux de contenu sous forme de liste d'enregistrements bruts
    fn parse_content(&self, content: &str) -> Result<Vec<RawRecordDto>, IngestionError>;
}

/// Registre des adaptateurs de sources disponibles.
pub struct AdapterRegistry {
    adapters: HashMap<SourceFormat, Arc<dyn SourceAdapter>>,
}

impl AdapterRegistry {
    /// Crée un registre initialisé avec les adaptateurs officiels
    pub fn new() -> Self {
        let mut registry = Self {
            adapters: HashMap::new(),
        };
        registry.register(Arc::new(FabDisAdapter::new()));
        registry.register(Arc::new(CsvAdapter::new()));
        registry.register(Arc::new(XmlAdapter::new()));
        registry.register(Arc::new(JsonAdapter::new()));
        registry
    }

    /// Enregistre un adaptateur
    pub fn register(&mut self, adapter: Arc<dyn SourceAdapter>) {
        self.adapters.insert(adapter.format(), adapter);
    }

    /// Récupère l'adaptateur correspondant à un format source
    pub fn get(&self, format: SourceFormat) -> Option<Arc<dyn SourceAdapter>> {
        self.adapters.get(&format).cloned()
    }
}

impl Default for AdapterRegistry {
    fn default() -> Self {
        Self::new()
    }
}
