//! Fichier XLIFF 2.0 : un `<file>` par espace de noms, un `<unit>` par clé, texte seul dans
//! `<source>` et `<target>` (les éléments en ligne du format sont refusés).

use std::io::{Read, Write};

use lyxal_parsing::{Limits, ReadFailure, XmlOptions, XmlReader};

use super::{ExchangeError, ReadOutcome, RejectedRecord};
use crate::models::{ExportRow, ImportEntry};

pub(super) fn read(input: &mut dyn Read) -> Result<ReadOutcome, ExchangeError> {
    let options = XmlOptions {
        record_elements: vec!["unit".to_string()],
        limits: Limits::default(),
        ..XmlOptions::default()
    };
    let mut entries = Vec::new();
    let mut rejected = Vec::new();
    for item in XmlReader::new(input, options) {
        match item {
            Ok(record) => {
                let line = record.position.line;
                let key = record.get("@id").map(str::to_string);
                let mut reject = |cause: &str| {
                    rejected.push(RejectedRecord {
                        line,
                        key: key.clone(),
                        cause: cause.to_string(),
                    });
                };
                let Some(id) = key.clone() else {
                    reject("attribut id absent");
                    continue;
                };
                if record.get_all("segment/source").count() > 1 {
                    reject("plusieurs segments dans une unité");
                    continue;
                }
                let inline = record.fields.iter().any(|(path, _)| {
                    ["segment/source/", "segment/target/"].iter().any(|prefix| {
                        path.strip_prefix(prefix)
                            .is_some_and(|rest| !rest.starts_with('@'))
                    })
                });
                if inline {
                    reject("élément en ligne non pris en charge (texte seul attendu)");
                    continue;
                }
                // Unité sans cible : clé non traduite, rien à importer
                if let Some(text) = record.get("segment/target") {
                    entries.push(ImportEntry {
                        key: id,
                        text: text.to_string(),
                        syntax: None,
                    });
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

pub(super) fn write(
    rows: &[ExportRow],
    locale: &str,
    output: &mut dyn Write,
) -> Result<(), ExchangeError> {
    let mut sources: Vec<&str> = rows.iter().map(|row| row.source_locale.as_str()).collect();
    sources.sort_unstable();
    sources.dedup();
    if sources.len() > 1 {
        return Err(ExchangeError::MixedSourceLocales(sources.join(", ")));
    }
    let source = sources.first().copied().unwrap_or(locale);
    writeln!(output, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")?;
    writeln!(
        output,
        "<xliff xmlns=\"urn:oasis:names:tc:xliff:document:2.0\" version=\"2.0\" srcLang=\"{}\" trgLang=\"{}\">",
        escape(source),
        escape(locale)
    )?;
    let mut namespace: Option<&str> = None;
    for row in rows {
        if namespace != Some(row.namespace.as_str()) {
            if namespace.is_some() {
                writeln!(output, "  </file>")?;
            }
            writeln!(output, "  <file id=\"{}\">", escape(&row.namespace))?;
            namespace = Some(row.namespace.as_str());
        }
        writeln!(
            output,
            "    <unit id=\"{}\" xml:space=\"preserve\">",
            escape(&row.key)
        )?;
        if let Some(description) = &row.description {
            writeln!(
                output,
                "      <notes><note>{}</note></notes>",
                escape(description)
            )?;
        }
        let state = match row.state.as_str() {
            "reviewed" => "reviewed",
            "translated" => "translated",
            _ => "initial",
        };
        writeln!(output, "      <segment state=\"{state}\">")?;
        writeln!(
            output,
            "        <source>{}</source>",
            escape(row.source_text.as_deref().unwrap_or_default())
        )?;
        if let Some(text) = &row.text {
            writeln!(output, "        <target>{}</target>", escape(text))?;
        }
        writeln!(output, "      </segment>")?;
        writeln!(output, "    </unit>")?;
    }
    if namespace.is_some() {
        writeln!(output, "  </file>")?;
    }
    writeln!(output, "</xliff>")?;
    Ok(())
}

/// Échappe les cinq caractères réservés de XML.
fn escape(text: &str) -> String {
    let mut escaped = String::with_capacity(text.len());
    for character in text.chars() {
        match character {
            '&' => escaped.push_str("&amp;"),
            '<' => escaped.push_str("&lt;"),
            '>' => escaped.push_str("&gt;"),
            '"' => escaped.push_str("&quot;"),
            '\'' => escaped.push_str("&apos;"),
            other => escaped.push(other),
        }
    }
    escaped
}
