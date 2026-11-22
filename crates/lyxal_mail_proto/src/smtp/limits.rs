// SPDX-License-Identifier: AGPL-3.0-only

//! Limites appliquées par la syntaxe SMTP (décision S19). Les autres limites de la session
//! (destinataires, messages par session, erreurs, délais) appartiennent à `lyxal_mail`.

/// Longueur minimale d'une ligne de commande, CRLF compris (RFC 5321 §4.5.3.1.4).
pub const MIN_LINE_BYTES: usize = 512;
/// Longueur maximale réglable d'une ligne de commande.
pub const MAX_LINE_BYTES: usize = 65_536;
/// Longueur par défaut d'une ligne de commande (`max_line_bytes`).
pub const DEFAULT_LINE_BYTES: usize = 4_096;
/// Taille minimale réglable d'un message (1 Mio).
pub const MIN_MESSAGE_BYTES: u64 = 1 << 20;
/// Taille maximale réglable d'un message (1 Gio).
pub const MAX_MESSAGE_BYTES: u64 = 1 << 30;
/// Taille par défaut d'un message (50 Mio, `max_message_bytes`, annoncée par `SIZE`).
pub const DEFAULT_MESSAGE_BYTES: u64 = 50 << 20;

/// Réglage hors bornes.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum LimitError {
    /// `max_line_bytes` hors de [`MIN_LINE_BYTES`] à [`MAX_LINE_BYTES`].
    #[error("max_line_bytes hors des bornes 512 à 65 536")]
    LineBytes,
    /// `max_message_bytes` hors de [`MIN_MESSAGE_BYTES`] à [`MAX_MESSAGE_BYTES`].
    #[error("max_message_bytes hors des bornes 1 Mio à 1 Gio")]
    MessageBytes,
}

/// Limites de lecture d'une session SMTP.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct SmtpLimits {
    max_line_bytes: usize,
    max_message_bytes: u64,
}

impl SmtpLimits {
    /// Limites contrôlées.
    pub fn new(max_line_bytes: usize, max_message_bytes: u64) -> Result<Self, LimitError> {
        if !(MIN_LINE_BYTES..=MAX_LINE_BYTES).contains(&max_line_bytes) {
            return Err(LimitError::LineBytes);
        }
        if !(MIN_MESSAGE_BYTES..=MAX_MESSAGE_BYTES).contains(&max_message_bytes) {
            return Err(LimitError::MessageBytes);
        }
        Ok(Self {
            max_line_bytes,
            max_message_bytes,
        })
    }

    /// Longueur maximale d'une ligne de commande, CRLF compris.
    pub const fn max_line_bytes(&self) -> usize {
        self.max_line_bytes
    }

    /// Taille maximale d'un message (après retrait du bourrage de `DATA`) ; au-delà, les
    /// octets sont lus sans être gardés.
    pub const fn max_message_bytes(&self) -> u64 {
        self.max_message_bytes
    }
}

impl Default for SmtpLimits {
    /// 4 096 octets par ligne, 50 Mio par message (décision S19).
    fn default() -> Self {
        Self {
            max_line_bytes: DEFAULT_LINE_BYTES,
            max_message_bytes: DEFAULT_MESSAGE_BYTES,
        }
    }
}
