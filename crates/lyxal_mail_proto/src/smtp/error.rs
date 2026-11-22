// SPDX-License-Identifier: AGPL-3.0-only

//! Refus de lecture d'une commande ou de données SMTP. Aucune donnée du client n'y figure.

use super::response::{EnhancedStatus, Response};

/// Commande ou données refusées. [`SmtpError::response`] donne la réponse normalisée ; la
/// session (`lyxal_mail`) l'envoie, compte l'erreur pour `max_errors` et poursuit le dialogue :
/// la ligne fautive est entièrement consommée, le flux reste synchronisé.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum SmtpError {
    /// Verbe inconnu ou ligne vide.
    #[error("commande SMTP inconnue")]
    UnknownCommand,
    /// Arguments d'une commande connue mal formés (nom de la commande).
    #[error("arguments de {0} mal formés")]
    Syntax(&'static str),
    /// Chemin de `MAIL FROM` mal formé.
    #[error("adresse d'expéditeur mal formée")]
    InvalidSender,
    /// Chemin de `RCPT TO` mal formé.
    #[error("adresse de destinataire mal formée")]
    InvalidRecipient,
    /// Valeur d'un paramètre connu mal formée (nom du paramètre).
    #[error("valeur du paramètre {0} invalide")]
    InvalidParameter(&'static str),
    /// Paramètre connu répété (nom du paramètre).
    #[error("paramètre {0} répété")]
    DuplicateParameter(&'static str),
    /// Paramètre inconnu ou d'une extension non annoncée (RFC 5321 §4.1.1.11).
    #[error("paramètre non pris en charge")]
    UnsupportedParameter,
    /// Expéditeur non ASCII sans le paramètre `SMTPUTF8` (RFC 6531 §3.4).
    #[error("adresse non ASCII sans SMTPUTF8")]
    Utf8WithoutSmtpUtf8,
    /// Ligne de commande plus longue que la limite (`max_line_bytes`).
    #[error("ligne de commande trop longue")]
    LineTooLong,
    /// CR non suivi de LF (contrebande SMTP, décision S7).
    #[error("CR isolé")]
    BareCr,
    /// LF non précédé de CR (contrebande SMTP, décision S7).
    #[error("LF isolé")]
    BareLf,
    /// Octet nul dans une ligne de commande.
    #[error("octet nul")]
    NulByte,
    /// Ligne de commande qui n'est pas de l'UTF-8 valide.
    #[error("ligne de commande en UTF-8 invalide")]
    InvalidUtf8,
}

impl SmtpError {
    /// Réponse normalisée : code de la RFC 5321 §4.2, code étendu de la RFC 3463, texte sans
    /// donnée du client.
    pub fn response(&self) -> Response {
        let (code, class, subject, detail, text) = match self {
            SmtpError::UnknownCommand => (500, 5, 5, 1, "Command not recognized"),
            SmtpError::Syntax(_) => (501, 5, 5, 4, "Syntax error in command arguments"),
            SmtpError::InvalidSender => (501, 5, 1, 7, "Bad sender address syntax"),
            SmtpError::InvalidRecipient => (501, 5, 1, 3, "Bad recipient address syntax"),
            SmtpError::InvalidParameter(_) | SmtpError::DuplicateParameter(_) => {
                (501, 5, 5, 4, "Invalid command parameter")
            }
            SmtpError::UnsupportedParameter => (555, 5, 5, 4, "Parameter not supported"),
            SmtpError::Utf8WithoutSmtpUtf8 => (553, 5, 6, 7, "Non-ASCII address requires SMTPUTF8"),
            SmtpError::LineTooLong => (500, 5, 5, 2, "Line too long"),
            SmtpError::BareCr | SmtpError::BareLf => (
                500,
                5,
                5,
                2,
                "Bare CR or LF not allowed, possible SMTP smuggling",
            ),
            SmtpError::NulByte => (500, 5, 5, 2, "NUL byte not allowed"),
            SmtpError::InvalidUtf8 => (500, 5, 5, 2, "Invalid UTF-8 in command"),
        };
        Response::fixed(code, EnhancedStatus::known(class, subject, detail), text)
    }
}
