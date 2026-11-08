//! # lyxal_parsing
//!
//! Lecture des formats sources du Noyau Technique Lyxal OS : CSV (bibliothèque `csv`), JSON
//! (`serde_json`) et XML (`quick-xml`), en flux, sans base de données ni logique métier.
//!
//! Chaque lecteur est un itérateur dont chaque élément est :
//!
//! * un enregistrement, avec ses valeurs telles que lues (aucun `trim`, aucune conversion) ;
//! * un [`ReadFailure::Rejected`] : l'enregistrement est écarté avec sa position et sa cause
//!   (code `PARSING_*`), la lecture continue ;
//! * un [`ReadFailure::Fatal`] : la suite de la source n'est plus fiable, c'est le dernier
//!   élément rendu.
//!
//! Aucun enregistrement n'est ignoré sans être rendu ou rejeté. L'encodage est toujours déclaré
//! par l'appelant ([`SourceEncoding`]) ; la mémoire utilisée par enregistrement est bornée
//! ([`Limits`]). Le choix des colonnes et balises, la normalisation et la qualification restent
//! dans le module consommateur (ex. `lyxal_pipeline_ingestion`).

mod common;
pub mod csv;
pub mod json;
pub mod xml;

pub use common::{
    Limits, ParseError, Position, ReadFailure, Rejection, RejectionKind, SourceEncoding,
};
pub use csv::{CsvHeader, CsvOptions, CsvReader, CsvRecord, Delimiter};
pub use json::{JsonLayout, JsonOptions, JsonReader, JsonRecord};
pub use xml::{XmlOptions, XmlReader, XmlRecord};
