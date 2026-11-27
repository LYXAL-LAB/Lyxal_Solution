// SPDX-License-Identifier: AGPL-3.0-only

//! Extensions annoncées par un serveur distant dans sa réponse à `EHLO` (RFC 5321 §4.1.1.1).
//!
//! Écrit pour Lyxal OS sur le modèle de Mox (`smtpclient/client.go`, `hello` : mots-clés sans
//! égard à la casse, paramètre de `SMTPUTF8` ignoré, `SIZE` sans valeur lisible gardé comme
//! annoncé, mots inconnus ignorés) et de Stalwart `smtp-proto` (`EhloResponse::parse` :
//! mécanismes de `AUTH`, forme ancienne `AUTH=`).

use super::super::auth::MAX_MECHANISM_BYTES;
use super::super::command::is_mechanism_byte;
use super::super::response::Response;

/// Nombre maximal de mécanismes `AUTH` gardés ; les suivants sont ignorés.
pub const MAX_AUTH_MECHANISMS: usize = 32;

/// Extensions du serveur distant. Les mots inconnus sont ignorés.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct ServerExtensions {
    /// Premier mot de la première ligne (nom annoncé par le serveur), assaini.
    pub hostname: String,
    /// `PIPELINING` (RFC 2920).
    pub pipelining: bool,
    /// `SIZE` (RFC 1870) : `Some(0)` annoncé sans taille maximale (valeur absente, nulle ou
    /// illisible), `Some(n)` taille maximale d'un message en octets.
    pub size: Option<u64>,
    /// `8BITMIME` (RFC 6152).
    pub eight_bit_mime: bool,
    /// `SMTPUTF8` (RFC 6531).
    pub smtputf8: bool,
    /// `STARTTLS` (RFC 3207).
    pub starttls: bool,
    /// `DSN` (RFC 3461).
    pub dsn: bool,
    /// `ENHANCEDSTATUSCODES` (RFC 2034).
    pub enhanced_status_codes: bool,
    /// `CHUNKING` (RFC 3030).
    pub chunking: bool,
    /// `REQUIRETLS` (RFC 8689).
    pub requiretls: bool,
    /// Mécanismes de `AUTH` (RFC 4954), en capitales, sans doublon, dans l'ordre annoncé.
    pub auth: Vec<String>,
}

impl ServerExtensions {
    /// Lit une réponse `250` à `EHLO` (lue sans code étendu, [`super::ReplyReader::new`]) ;
    /// `None` pour un autre code.
    pub fn from_ehlo(reply: &Response) -> Option<Self> {
        if reply.code() != 250 {
            return None;
        }
        let mut lines = reply.lines().iter();
        let mut extensions = Self {
            hostname: lines
                .next()
                .and_then(|line| line.split(' ').next())
                .unwrap_or_default()
                .to_owned(),
            ..Self::default()
        };
        for line in lines {
            extensions.keyword(line.trim());
        }
        Some(extensions)
    }

    /// Taille maximale d'un message annoncée par `SIZE`, s'il y en a une.
    pub fn max_message_size(&self) -> Option<u64> {
        self.size.filter(|&size| size > 0)
    }

    /// Vrai si le mécanisme `AUTH` nommé est annoncé (sans égard à la casse).
    pub fn supports_auth(&self, mechanism: &str) -> bool {
        self.auth
            .iter()
            .any(|known| known.eq_ignore_ascii_case(mechanism))
    }

    fn keyword(&mut self, line: &str) {
        let (keyword, params) = match line.find([' ', '=']) {
            Some(index) => (&line[..index], line[index + 1..].trim()),
            None => (line, ""),
        };
        let keyword = keyword.to_ascii_uppercase();
        match keyword.as_str() {
            "PIPELINING" => self.pipelining = true,
            "8BITMIME" => self.eight_bit_mime = true,
            // RFC 6531 §3.3 : un paramètre éventuel est ignoré.
            "SMTPUTF8" => self.smtputf8 = true,
            "STARTTLS" => self.starttls = true,
            "DSN" => self.dsn = true,
            "ENHANCEDSTATUSCODES" => self.enhanced_status_codes = true,
            "CHUNKING" => self.chunking = true,
            "REQUIRETLS" => self.requiretls = true,
            "SIZE" => {
                // RFC 1870 §4 : `SIZE` seul ou `SIZE 0` : aucune taille maximale.
                let size = params
                    .split(' ')
                    .next()
                    .filter(|value| value.len() <= 20 && value.bytes().all(|b| b.is_ascii_digit()))
                    .and_then(|value| value.parse().ok())
                    .unwrap_or(0);
                self.size = Some(size);
            }
            "AUTH" => {
                for mechanism in params.split([' ', '=']).filter(|word| !word.is_empty()) {
                    let valid = mechanism.len() <= MAX_MECHANISM_BYTES
                        && mechanism.bytes().all(is_mechanism_byte);
                    if valid
                        && self.auth.len() < MAX_AUTH_MECHANISMS
                        && !self.supports_auth(mechanism)
                    {
                        self.auth.push(mechanism.to_ascii_uppercase());
                    }
                }
            }
            _ => {}
        }
    }
}
