//! Valeurs des arguments d'un message.

use std::collections::BTreeMap;

use fixed_decimal::Decimal;
use jiff::Timestamp;

use super::FormatError;

/// Valeur d'un argument.
#[derive(Debug, Clone, PartialEq)]
pub enum ArgValue {
    /// Texte, rendu tel quel.
    Text(String),
    /// Nombre décimal exact.
    Number(Decimal),
    /// Instant.
    DateTime(Timestamp),
}

/// Arguments d'un message, par nom.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct MessageArgs(BTreeMap<String, ArgValue>);

impl MessageArgs {
    /// Aucun argument.
    pub fn new() -> Self {
        Self::default()
    }

    /// Ajoute un texte.
    pub fn text(mut self, name: &str, value: impl Into<String>) -> Self {
        self.0
            .insert(name.to_string(), ArgValue::Text(value.into()));
        self
    }

    /// Ajoute un nombre entier.
    pub fn integer(mut self, name: &str, value: i64) -> Self {
        self.0
            .insert(name.to_string(), ArgValue::Number(Decimal::from(value)));
        self
    }

    /// Ajoute un nombre depuis son écriture décimale (`"1234.56"`), sans passer par un flottant.
    pub fn decimal(mut self, name: &str, value: &str) -> Result<Self, FormatError> {
        self.0
            .insert(name.to_string(), ArgValue::Number(parse_decimal(value)?));
        Ok(self)
    }

    /// Ajoute un instant.
    pub fn datetime(mut self, name: &str, value: Timestamp) -> Self {
        self.0.insert(name.to_string(), ArgValue::DateTime(value));
        self
    }

    /// Valeur d'un argument.
    pub fn get(&self, name: &str) -> Option<&ArgValue> {
        self.0.get(name)
    }
}

/// Nombre décimal exact depuis son écriture (`"-1234.50"`).
pub fn parse_decimal(value: &str) -> Result<Decimal, FormatError> {
    value
        .trim()
        .parse::<Decimal>()
        .map_err(|_| FormatError::NumberInvalid {
            value: value.to_string(),
        })
}
