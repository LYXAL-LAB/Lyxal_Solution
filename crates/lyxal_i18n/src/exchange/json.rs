//! Fichier JSON à plat : `{ "clé": "texte" }`, le format d'échange de Tolgee et de FormatJS.

use std::io::{Read, Write};

use lyxal_parsing::{JsonLayout, JsonOptions, JsonReader, Limits, ReadFailure};

use super::{ExchangeError, ReadOutcome, RejectedRecord};
use crate::models::{ExportRow, ImportEntry};

/// Limites d'un fichier de textes : un seul objet, bien plus grand qu'un enregistrement courant.
const LIMITS: Limits = Limits {
    max_record_bytes: 64 * 1024 * 1024,
    max_fields: 200_000,
    max_depth: 2,
};

pub(super) fn read(input: &mut dyn Read) -> Result<ReadOutcome, ExchangeError> {
    let options = JsonOptions {
        layout: JsonLayout::Document,
        limits: LIMITS,
        ..JsonOptions::default()
    };
    let mut entries = Vec::new();
    let mut rejected = Vec::new();
    for item in JsonReader::new(input, options) {
        match item {
            Ok(record) => {
                for (key, value) in record.value {
                    match value {
                        serde_json::Value::String(text) => entries.push(ImportEntry {
                            key,
                            text,
                            syntax: None,
                        }),
                        _ => rejected.push(RejectedRecord {
                            line: None,
                            key: Some(key),
                            cause: "texte attendu".to_string(),
                        }),
                    }
                }
            }
            Err(ReadFailure::Rejected(rejection)) => rejected.push(RejectedRecord {
                line: rejection.position.line,
                key: None,
                cause: format!("{} : {}", rejection.kind.code(), rejection.detail),
            }),
            Err(ReadFailure::Fatal(error)) => return Err(ExchangeError::Parse(error)),
        }
    }
    Ok((entries, rejected))
}

/// Écrit les clés traduites, dans l'ordre reçu (trié par clé), une par ligne.
pub(super) fn write(rows: &[ExportRow], output: &mut dyn Write) -> Result<(), ExchangeError> {
    let translated: Vec<(&str, &str)> = rows
        .iter()
        .filter_map(|row| row.text.as_deref().map(|text| (row.key.as_str(), text)))
        .collect();
    output.write_all(b"{")?;
    for (index, (key, text)) in translated.iter().enumerate() {
        let separator = if index == 0 { "\n" } else { ",\n" };
        write!(output, "{separator}  {}: {}", quoted(key)?, quoted(text)?)?;
    }
    output.write_all(if translated.is_empty() {
        b"}\n"
    } else {
        b"\n}\n"
    })?;
    Ok(())
}

fn quoted(text: &str) -> Result<String, ExchangeError> {
    serde_json::to_string(text).map_err(|error| ExchangeError::Io(error.into()))
}
