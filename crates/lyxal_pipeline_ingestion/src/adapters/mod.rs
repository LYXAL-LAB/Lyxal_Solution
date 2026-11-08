//! Adaptateurs de sources pour l'ingestion multiformat de Lyxal OS.
//!
//! La lecture des formats (CSV, JSON, XML, encodage, rejets) est faite par `lyxal_parsing` ; un
//! adaptateur ne fait que la correspondance métier des colonnes et balises vers un
//! [`RawRecordDto`] :
//! - FAB-DIS 2.3 (blocs sans en-tête) et 3.0 (tabulaire)
//! - CSV (séparateur détecté)
//! - XML (BMEcat et catalogues hiérarchiques)
//! - JSON (tableau d'objets et NDJSON)

pub mod csv;
pub mod fab_dis;
pub mod json;
pub mod xml;

pub use csv::CsvAdapter;
pub use fab_dis::FabDisAdapter;
pub use json::JsonAdapter;
pub use xml::XmlAdapter;

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::Arc;

use crate::error::IngestionError;
use crate::types::{SourceEncoding, SourceFormat};

/// Enregistrement brut extrait d'une source avant normalisation.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct RawRecordDto {
    /// Numéro de l'enregistrement dans la suite de la source (à partir de 1, rejets compris) :
    /// identité de la ligne brute `<lot>_<numéro>`.
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
    /// Contenu lu (avec la ligne physique de la source) pour audit et traçabilité immuable
    pub raw_payload: serde_json::Value,
    /// Hachage BLAKE3 de l'enregistrement lu
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

/// Enregistrement écarté à la lecture : il garde son numéro et devient une anomalie de
/// quarantaine.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SourceRejection {
    /// Numéro de l'enregistrement dans la suite de la source.
    pub record: usize,
    /// Ligne physique de début dans le fichier, quand le format la fournit.
    pub source_line: Option<u64>,
    /// Code de l'anomalie consignée (`INGESTION_*`).
    pub anomaly_code: &'static str,
    /// Cause précise : code `PARSING_*` de `lyxal_parsing` ou code de l'adaptateur.
    pub cause_code: String,
    /// Diagnostic, sans le contenu de l'enregistrement.
    pub detail: String,
}

impl SourceRejection {
    /// Rejet rendu par un lecteur de `lyxal_parsing`.
    pub(crate) fn from_parsing(rejection: lyxal_parsing::Rejection) -> Self {
        Self {
            record: rejection.position.record as usize,
            source_line: rejection.position.line,
            anomaly_code: "INGESTION_SOURCE_RECORD_REJECTED",
            cause_code: rejection.kind.code().to_string(),
            detail: rejection.detail,
        }
    }
}

/// Élément lu d'une source, dans l'ordre de la source.
#[derive(Debug, Clone, PartialEq)]
pub enum SourceItem {
    /// Enregistrement lu et mis en correspondance (en boîte : bien plus grand qu'un rejet).
    Record(Box<RawRecordDto>),
    /// Enregistrement écarté.
    Rejected(SourceRejection),
}

impl SourceItem {
    /// Numéro de l'élément dans la suite de la source.
    pub fn number(&self) -> usize {
        match self {
            Self::Record(record) => record.line_number,
            Self::Rejected(rejection) => rejection.record,
        }
    }
}

/// Erreur d'arrêt de `lyxal_parsing` : la source est illisible (`INGESTION_SOURCE_INVALID`).
pub(crate) fn source_invalid(error: lyxal_parsing::ParseError) -> IngestionError {
    IngestionError::SourceInvalid {
        code: error.code().to_string(),
        detail: error.to_string(),
    }
}

/// Empreinte BLAKE3 de couples (nom, valeur) lus, sans ambiguïté de découpage (longueurs en
/// préfixe).
pub(crate) fn fields_hash(fields: &[(String, String)]) -> String {
    let mut canonical = String::new();
    for (name, value) in fields {
        canonical.push_str(&format!("{}:{name}{}:{value}", name.len(), value.len()));
    }
    lyxal_crypto::blake3_hex(canonical.as_bytes())
}

/// Élément de la source correspondant à un résultat de lecture de `lyxal_parsing`.
pub(crate) fn read_item<T>(
    item: Result<T, lyxal_parsing::ReadFailure>,
    map: impl FnOnce(T) -> RawRecordDto,
) -> Result<SourceItem, IngestionError> {
    match item {
        Ok(record) => Ok(SourceItem::Record(Box::new(map(record)))),
        Err(lyxal_parsing::ReadFailure::Rejected(rejection)) => Ok(SourceItem::Rejected(
            SourceRejection::from_parsing(rejection),
        )),
        Err(lyxal_parsing::ReadFailure::Fatal(error)) => Err(source_invalid(error)),
    }
}

/// Contrat universel d'un adaptateur de source d'ingestion.
pub trait SourceAdapter: Send + Sync {
    /// Format de source géré par l'adaptateur
    fn format(&self) -> SourceFormat;

    /// Lit toute la source (encodage déclaré du lot) : chaque élément est un enregistrement ou
    /// un rejet, dans l'ordre de la source ; une source illisible renvoie
    /// [`IngestionError::SourceInvalid`] sans aucun élément.
    fn read(
        &self,
        source: &[u8],
        encoding: SourceEncoding,
    ) -> Result<Vec<SourceItem>, IngestionError>;
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

/// Liste de records déjà mis en correspondance (tests) : enregistrements seuls.
#[cfg(test)]
pub(crate) fn records_only(items: Vec<SourceItem>) -> Vec<RawRecordDto> {
    items
        .into_iter()
        .filter_map(|item| match item {
            SourceItem::Record(record) => Some(*record),
            SourceItem::Rejected(_) => None,
        })
        .collect()
}
