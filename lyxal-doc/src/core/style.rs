use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SemanticStyle {
    pub name: String,
    pub description: Option<String>,
    // Ici, on pourrait ajouter des attributs sémantiques personnalisés
    // Mais on évite absolument les notions de pixels/couleurs ici.
    pub attributes: BTreeMap<String, String>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, Default)]
pub struct StyleSheet {
    pub styles: BTreeMap<String, SemanticStyle>,
}

