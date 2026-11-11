//! Échange des textes par fichier : export, import et contrôle de tous les textes.
//!
//! Un fichier porte une langue et une portée (installation, ou une organisation), données par
//! l'appelant. Lecture par `lyxal_parsing` ; les règles (texte relu protégé, clé inconnue,
//! contrôle des paramètres) sont celles de `fn::i18n_import`. Chaque texte importé est d'abord
//! vérifié par le rendu (`Formatter::check_message`). Aucune erreur n'est masquée.

mod json;
mod xliff;

use std::collections::HashMap;
use std::io::{Read, Write};

use lyxal_parsing::ParseError;
use lyxal_surreal::LyxalSurrealError;

use crate::format::{FormatError, Formatter, Syntax};
use crate::models::{
    ExportParams, ExportRow, ImportEntry, ImportParams, MessageProblem, PageParams,
};
use crate::store::I18nStore;

/// Taille d'une page d'export, d'un paquet d'import et d'une page de contrôle.
const PAGE: usize = 500;

/// Format d'un fichier de textes.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FileFormat {
    /// Objet JSON à plat `{ "clé": "texte" }`, textes en ICU MessageFormat 1.
    Json,
    /// XLIFF 2.0 : un `<file>` par espace de noms, un `<unit>` par clé.
    Xliff,
}

impl FileFormat {
    /// Format depuis son nom (`json`, `xliff`).
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "json" => Some(Self::Json),
            "xliff" => Some(Self::Xliff),
            _ => None,
        }
    }
}

/// Textes à exporter.
#[derive(Debug, Clone)]
pub struct ExportOptions {
    /// Étiquette de la langue.
    pub locale: String,
    /// Espace de noms (clé) ; tous si absent.
    pub namespace: Option<String>,
    /// Organisation dont les surcharges remplacent les textes de l'installation (texte).
    pub tenant: Option<String>,
}

/// Portée et règles d'un import.
#[derive(Debug, Clone)]
pub struct ImportOptions {
    /// Étiquette de la langue.
    pub locale: String,
    /// Organisation surchargée (texte), installation si absente.
    pub tenant: Option<String>,
    /// Écrase un texte à l'état `reviewed`.
    pub overwrite_reviewed: bool,
    /// Rend le rapport sans rien écrire.
    pub dry_run: bool,
}

/// Entrée ignorée.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SkippedEntry {
    /// Clé complète.
    pub key: String,
    /// Raison : `key_not_found`, `reviewed`, ou code d'erreur de l'écriture.
    pub reason: String,
}

/// Entrée refusée : par le rendu (`error`) ou par le contrôle de la base (`problems`).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct InvalidEntry {
    /// Clé complète.
    pub key: String,
    /// Problèmes relevés par la base.
    pub problems: Vec<MessageProblem>,
    /// Erreur du rendu (syntaxe complète du message).
    pub error: Option<FormatError>,
}

/// Enregistrement du fichier qui n'a pas pu être lu comme une entrée.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RejectedRecord {
    /// Ligne dans le fichier, si elle est connue.
    pub line: Option<u64>,
    /// Clé de l'entrée, si elle a pu être lue.
    pub key: Option<String>,
    /// Cause.
    pub cause: String,
}

/// Rapport d'un import.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct ImportReport {
    /// Textes créés.
    pub created: u64,
    /// Textes modifiés.
    pub updated: u64,
    /// Textes identiques à ceux de la base.
    pub unchanged: u64,
    /// Entrées ignorées (clé non déclarée, texte relu).
    pub skipped: Vec<SkippedEntry>,
    /// Entrées refusées, non écrites.
    pub invalid: Vec<InvalidEntry>,
    /// Enregistrements illisibles du fichier.
    pub rejected: Vec<RejectedRecord>,
}

impl ImportReport {
    /// Vrai si une entrée a été refusée ou n'a pas pu être lue.
    pub fn has_failures(&self) -> bool {
        !self.invalid.is_empty() || !self.rejected.is_empty()
    }
}

/// Texte que le rendu refuse.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct InvalidText {
    /// Clé complète.
    pub key: String,
    /// Étiquette de la langue.
    pub locale: String,
    /// Organisation de la surcharge (texte), absente pour l'installation.
    pub tenant: Option<String>,
    /// Erreur du rendu.
    pub error: FormatError,
}

/// Rapport du contrôle de tous les textes.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct CheckReport {
    /// Nombre de textes vérifiés.
    pub checked: u64,
    /// Textes refusés par le rendu.
    pub invalid: Vec<InvalidText>,
}

/// Échec d'un échange.
#[derive(Debug, thiserror::Error)]
pub enum ExchangeError {
    /// Échec d'une fonction SurrealQL (erreur métier ou transport).
    #[error("{0}")]
    Store(Box<LyxalSurrealError>),
    /// Fichier illisible : rien n'a été écrit en base.
    #[error("{0}")]
    Parse(#[from] ParseError),
    /// Écriture du fichier impossible.
    #[error("écriture du fichier impossible : {0}")]
    Io(#[from] std::io::Error),
    /// Langue illisible par le rendu.
    #[error("{0}")]
    Format(#[from] FormatError),
    /// Export XLIFF de clés dont les textes sources n'ont pas la même langue.
    #[error("textes sources en plusieurs langues ({0}) : exportez un espace de noms à la fois")]
    MixedSourceLocales(String),
}

impl From<LyxalSurrealError> for ExchangeError {
    fn from(error: LyxalSurrealError) -> Self {
        Self::Store(Box::new(error))
    }
}

/// Export, import et contrôle des textes sur un store.
pub struct Exchange {
    store: I18nStore,
}

impl Exchange {
    /// Échange sur un store ; la session SurrealDB du store détermine l'appelant.
    pub fn new(store: I18nStore) -> Self {
        Self { store }
    }

    async fn rows(&self, options: &ExportOptions) -> Result<Vec<ExportRow>, ExchangeError> {
        let mut rows = Vec::new();
        loop {
            let page = self
                .store
                .export(ExportParams {
                    locale: options.locale.clone(),
                    namespace: options.namespace.clone(),
                    tenant: options.tenant.clone(),
                    limit: Some(PAGE as i64),
                    start: Some(rows.len() as i64),
                })
                .await?;
            let received = page.items.len();
            rows.extend(page.items);
            if received == 0 || rows.len() as i64 >= page.total {
                return Ok(rows);
            }
        }
    }

    /// Écrit les textes d'une langue dans `output` ; renvoie le nombre de clés exportées.
    pub async fn export(
        &self,
        options: &ExportOptions,
        format: FileFormat,
        output: &mut dyn Write,
    ) -> Result<u64, ExchangeError> {
        let rows = self.rows(options).await?;
        match format {
            FileFormat::Json => json::write(&rows, output)?,
            FileFormat::Xliff => xliff::write(&rows, &options.locale, output)?,
        }
        Ok(rows.len() as u64)
    }

    /// Importe un fichier dans une langue et une portée. Un fichier illisible n'écrit rien ;
    /// un texte que le rendu refuse est signalé et n'est pas envoyé à la base.
    pub async fn import(
        &self,
        options: &ImportOptions,
        format: FileFormat,
        input: &mut dyn Read,
    ) -> Result<ImportReport, ExchangeError> {
        let (entries, rejected) = match format {
            FileFormat::Json => json::read(input)?,
            FileFormat::Xliff => xliff::read(input)?,
        };
        let mut report = ImportReport {
            rejected,
            ..ImportReport::default()
        };
        // Syntaxe sous laquelle la base écrira chaque clé : celle du texte existant dans la
        // portée, sinon celle du texte source (le texte de l'installation ne compte pas pour
        // une organisation qui n'a pas encore de surcharge)
        let scoped = options.tenant.is_some();
        let syntaxes: HashMap<String, Option<String>> = self
            .rows(&ExportOptions {
                locale: options.locale.clone(),
                namespace: None,
                tenant: options.tenant.clone(),
            })
            .await?
            .into_iter()
            .map(|row| {
                let syntax = if scoped && !row.overridden {
                    row.source_syntax
                } else {
                    row.syntax
                };
                (row.key, syntax)
            })
            .collect();
        let formatter = Formatter::new(&options.locale)?;
        let mut accepted = Vec::with_capacity(entries.len());
        for entry in entries {
            let syntax = syntaxes
                .get(&entry.key)
                .and_then(|syntax| syntax.as_deref())
                .and_then(Syntax::parse);
            // Clé inconnue : laissée à la base, qui la signale
            match syntax.map(|syntax| formatter.check_message(&entry.text, syntax)) {
                Some(Err(error)) => report.invalid.push(InvalidEntry {
                    key: entry.key,
                    problems: Vec::new(),
                    error: Some(error),
                }),
                _ => accepted.push(entry),
            }
        }
        for batch in accepted.chunks(PAGE) {
            let result = self
                .store
                .import(ImportParams {
                    locale: options.locale.clone(),
                    entries: batch.to_vec(),
                    tenant: options.tenant.clone(),
                    overwrite_reviewed: options.overwrite_reviewed,
                    dry_run: options.dry_run,
                })
                .await?;
            report.created += u64::try_from(result.created).unwrap_or_default();
            report.updated += u64::try_from(result.updated).unwrap_or_default();
            report.unchanged += u64::try_from(result.unchanged).unwrap_or_default();
            report
                .skipped
                .extend(result.skipped.into_iter().map(|skipped| SkippedEntry {
                    key: skipped.key,
                    reason: skipped.reason,
                }));
            report
                .invalid
                .extend(result.invalid.into_iter().map(|invalid| InvalidEntry {
                    key: invalid.key,
                    problems: invalid.problems,
                    error: None,
                }));
        }
        Ok(report)
    }

    /// Vérifie tous les textes, toutes langues et toutes portées, par le rendu ; ne modifie rien.
    pub async fn check(&self) -> Result<CheckReport, ExchangeError> {
        let mut report = CheckReport::default();
        let mut formatters: HashMap<String, Formatter> = HashMap::new();
        loop {
            let page = self
                .store
                .translation_scan(PageParams {
                    limit: Some(PAGE as i64),
                    start: Some(report.checked as i64),
                })
                .await?;
            let received = page.items.len();
            for row in page.items {
                report.checked += 1;
                let outcome = match Syntax::parse(&row.syntax) {
                    None => Err(FormatError::MessageInvalid {
                        reason: format!("syntaxe inconnue : {}", row.syntax),
                        offset: 0,
                    }),
                    Some(syntax) => {
                        if !formatters.contains_key(&row.locale) {
                            formatters.insert(row.locale.clone(), Formatter::new(&row.locale)?);
                        }
                        formatters[&row.locale].check_message(&row.text, syntax)
                    }
                };
                if let Err(error) = outcome {
                    report.invalid.push(InvalidText {
                        key: row.key,
                        locale: row.locale,
                        tenant: row.tenant,
                        error,
                    });
                }
            }
            if received == 0 || report.checked as i64 >= page.total {
                return Ok(report);
            }
        }
    }
}

/// Entrée lue dans un fichier, ou enregistrement rejeté.
type ReadOutcome = (Vec<ImportEntry>, Vec<RejectedRecord>);
