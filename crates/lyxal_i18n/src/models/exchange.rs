//! Export, import et parcours des textes (`fn::i18n_export`, `fn::i18n_import`,
//! `fn::i18n_translation_scan`).

use lyxal_surreal::SurrealValue;

use super::translation::KeyParam;

/// Paramètres de `fn::i18n_export`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ExportParams {
    /// Étiquette de la langue.
    pub locale: String,
    /// Espace de noms (clé).
    pub namespace: Option<String>,
    /// Organisation dont la surcharge remplace le texte de l'installation (texte).
    pub tenant: Option<String>,
    /// Nombre maximal de lignes (1 à 1000, 500 par défaut).
    pub limit: Option<i64>,
    /// Décalage.
    pub start: Option<i64>,
}

/// Ligne d'export : une clé et son texte dans la langue demandée.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ExportRow {
    /// Clé complète.
    pub key: String,
    /// Espace de noms (clé).
    pub namespace: String,
    /// Contexte pour le traducteur.
    pub description: Option<String>,
    /// Paramètres attendus.
    pub params: Vec<KeyParam>,
    /// Longueur maximale d'un texte.
    pub max_length: Option<i64>,
    /// Langue du texte source.
    pub source_locale: String,
    /// Texte source.
    pub source_text: Option<String>,
    /// Texte dans la langue demandée ; absent si la clé n'est pas traduite.
    pub text: Option<String>,
    /// Syntaxe du texte, sinon celle du texte source.
    pub syntax: Option<String>,
    /// État : `untranslated`, `translated` ou `reviewed`.
    pub state: String,
    /// Texte source modifié depuis l'écriture.
    pub outdated: bool,
    /// Texte surchargé par l'organisation demandée.
    pub overridden: bool,
}

/// Résultat de `fn::i18n_export`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ExportPage {
    /// Lignes de la page.
    pub items: Vec<ExportRow>,
    /// Nombre total de clés.
    pub total: i64,
}

/// Entrée d'un import.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ImportEntry {
    /// Clé complète.
    pub key: String,
    /// Texte.
    pub text: String,
    /// Syntaxe ; par défaut celle du texte existant, sinon du texte source.
    pub syntax: Option<String>,
}

/// Paramètres de `fn::i18n_import`.
#[derive(Debug, Clone, SurrealValue)]
pub struct ImportParams {
    /// Étiquette de la langue.
    pub locale: String,
    /// Entrées (500 au plus).
    pub entries: Vec<ImportEntry>,
    /// Organisation surchargée (texte), installation si absente.
    pub tenant: Option<String>,
    /// Écrase un texte à l'état `reviewed`.
    pub overwrite_reviewed: bool,
    /// Rend le rapport sans rien écrire.
    pub dry_run: bool,
}

/// Entrée ignorée par un import.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ImportSkipped {
    /// Clé complète.
    pub key: String,
    /// Raison : `key_not_found`, `reviewed`, ou code d'erreur de l'écriture.
    pub reason: String,
}

/// Problème du contrôle d'un texte par la base.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct MessageProblem {
    /// Code (`unknown_argument`, `type_mismatch`, `too_long`…).
    pub code: String,
    /// Argument concerné.
    pub argument: Option<String>,
    /// Catégorie de pluriel concernée.
    pub category: Option<String>,
    /// Usage de l'argument dans le texte.
    #[surreal(rename = "type")]
    pub kind: Option<String>,
    /// Type déclaré du paramètre.
    pub expected: Option<String>,
    /// Longueur maximale de la clé.
    pub max_length: Option<i64>,
    /// Longueur du texte.
    pub length: Option<i64>,
}

/// Entrée refusée par le contrôle de la base.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ImportInvalid {
    /// Clé complète.
    pub key: String,
    /// Problèmes relevés.
    pub problems: Vec<MessageProblem>,
}

/// Résultat de `fn::i18n_import`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ImportResult {
    /// Textes créés.
    pub created: i64,
    /// Textes modifiés.
    pub updated: i64,
    /// Textes identiques à ceux de la base.
    pub unchanged: i64,
    /// Entrées ignorées.
    pub skipped: Vec<ImportSkipped>,
    /// Entrées refusées par le contrôle.
    pub invalid: Vec<ImportInvalid>,
}

/// Texte rendu par `fn::i18n_translation_scan`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ScanRow {
    /// Clé complète.
    pub key: String,
    /// Étiquette de la langue.
    pub locale: String,
    /// Organisation de la surcharge (texte), absente pour l'installation.
    pub tenant: Option<String>,
    /// Texte.
    pub text: String,
    /// Syntaxe.
    pub syntax: String,
}

/// Résultat de `fn::i18n_translation_scan`.
#[derive(Debug, Clone, PartialEq, Eq, SurrealValue)]
pub struct ScanPage {
    /// Textes de la page.
    pub items: Vec<ScanRow>,
    /// Nombre total de textes.
    pub total: i64,
}
