//! CSV Document Model
//!
//! Types représentant la structure d'un fichier CSV.

/// Document CSV parsé
#[derive(Debug, Clone, Default)]
pub struct CsvDocument {
    /// En-têtes (si présents)
    pub headers: Option<Vec<String>>,
    /// Lignes de données
    pub rows: Vec<Vec<String>>,
    /// Délimiteur détecté
    pub delimiter: char,
    /// Métadonnées
    pub metadata: std::collections::HashMap<String, String>,
}
