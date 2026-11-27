// SPDX-License-Identifier: AGPL-3.0-only

//! Réponses du serveur (RFC 5321 §4.2), codes étendus (RFC 3463, annoncés par
//! `ENHANCEDSTATUSCODES`, RFC 2034) et réponse à `EHLO` (extensions de la décision S5).
//!
//! Écrit pour Lyxal OS sur le modèle de Stalwart `smtp-proto` (`response/generate.rs`) et de
//! Mox (`smtpserver/server.go`, `smtp/codes.go`). Contrairement à la source, le texte d'une
//! réponse est assaini : aucun CR, LF, caractère de commande ni octet hors ASCII n'en sort
//! (aucune injection dans le dialogue), et chaque ligne tient en 512 octets
//! (RFC 5321 §4.5.3.1.5).

use std::fmt;

/// Longueur maximale d'une ligne de réponse, CRLF compris (RFC 5321 §4.5.3.1.5).
pub const MAX_REPLY_LINE_BYTES: usize = 512;

/// Code de statut étendu `classe.sujet.détail` (RFC 3463 §2).
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct EnhancedStatus {
    class: u8,
    subject: u16,
    detail: u16,
}

impl EnhancedStatus {
    /// Code étendu ; `None` si la classe n'est pas 2, 4 ou 5, ou si le sujet ou le détail
    /// dépasse 999.
    pub const fn new(class: u8, subject: u16, detail: u16) -> Option<Self> {
        if !matches!(class, 2 | 4 | 5) || subject > 999 || detail > 999 {
            return None;
        }
        Some(Self {
            class,
            subject,
            detail,
        })
    }

    /// Code connu valide, pour les réponses écrites dans ce crate.
    pub(crate) const fn known(class: u8, subject: u16, detail: u16) -> Self {
        Self {
            class,
            subject,
            detail,
        }
    }

    /// Lit `classe.sujet.détail` (`status-code` de la RFC 3463 §2 : `class "." subject "."
    /// detail`, 1 à 3 chiffres pour le sujet et le détail).
    pub fn parse(value: &str) -> Option<Self> {
        let mut parts = value.split('.');
        let class = parse_digits(parts.next()?, 1)?;
        let subject = parse_digits(parts.next()?, 3)?;
        let detail = parse_digits(parts.next()?, 3)?;
        if parts.next().is_some() {
            return None;
        }
        Self::new(u8::try_from(class).ok()?, subject, detail)
    }

    /// Classe : 2 (succès), 4 (échec temporaire), 5 (échec permanent).
    pub const fn class(&self) -> u8 {
        self.class
    }

    /// Sujet (RFC 3463 §3 : 0 à 7 définis).
    pub const fn subject(&self) -> u16 {
        self.subject
    }

    /// Détail.
    pub const fn detail(&self) -> u16 {
        self.detail
    }
}

fn parse_digits(value: &str, max_digits: usize) -> Option<u16> {
    if value.is_empty() || value.len() > max_digits || !value.bytes().all(|b| b.is_ascii_digit()) {
        return None;
    }
    value.parse().ok()
}

impl fmt::Display for EnhancedStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}.{}.{}", self.class, self.subject, self.detail)
    }
}

/// Réponse impossible à construire.
#[derive(Clone, Copy, Debug, PartialEq, Eq, thiserror::Error)]
pub enum ResponseError {
    /// Code hors de `2yz` à `5yz` ou deuxième chiffre au-delà de 5 (RFC 5321 §4.2.1).
    #[error("code de réponse SMTP invalide")]
    InvalidCode,
    /// La classe du code étendu ne correspond pas au premier chiffre du code, ou un code
    /// étendu accompagne une réponse `3yz` (RFC 3463 ne définit pas de classe 3).
    #[error("code étendu incohérent avec le code de réponse")]
    StatusMismatch,
    /// Nom d'hôte absent, trop long ou qui n'est pas un domaine ASCII.
    #[error("nom d'hôte invalide pour une réponse")]
    InvalidHostname,
}

/// Réponse du serveur, sur une ou plusieurs lignes.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Response {
    code: u16,
    status: Option<EnhancedStatus>,
    lines: Vec<String>,
}

impl Response {
    /// Réponse d'une ligne. Le texte est assaini (voir le module).
    pub fn new(
        code: u16,
        status: Option<EnhancedStatus>,
        text: &str,
    ) -> Result<Self, ResponseError> {
        Self::with_lines(code, status, [text])
    }

    /// Réponse de plusieurs lignes (`code-texte` puis `code texte`). Aucune ligne : une ligne
    /// vide.
    pub fn with_lines<I, S>(
        code: u16,
        status: Option<EnhancedStatus>,
        lines: I,
    ) -> Result<Self, ResponseError>
    where
        I: IntoIterator<Item = S>,
        S: AsRef<str>,
    {
        check_code(code, status)?;
        let prefix = prefix_len(status);
        let mut lines: Vec<String> = lines
            .into_iter()
            .map(|line| sanitize(line.as_ref(), MAX_REPLY_LINE_BYTES - prefix - 2))
            .collect();
        if lines.is_empty() {
            lines.push(String::new());
        }
        Ok(Self {
            code,
            status,
            lines,
        })
    }

    /// Réponse d'une ligne écrite dans ce crate (code, code étendu et texte ASCII connus
    /// valides, vérifiés par les essais).
    pub(crate) fn fixed(code: u16, status: EnhancedStatus, text: &str) -> Self {
        Self {
            code,
            status: Some(status),
            lines: vec![text.to_owned()],
        }
    }

    /// Défi `334` d'un échange `AUTH` (texte Base64 écrit dans ce crate, ASCII connu valide).
    pub(crate) fn continuation(text: &str) -> Self {
        Self {
            code: 334,
            status: None,
            lines: vec![text.to_owned()],
        }
    }

    /// Accueil `220 <hostname> ESMTP` (plan §7.2 : aucun nom ni version de logiciel).
    pub fn greeting(hostname: &str) -> Result<Self, ResponseError> {
        check_hostname(hostname)?;
        Self::new(220, None, &format!("{hostname} ESMTP"))
    }

    /// Code à trois chiffres.
    pub const fn code(&self) -> u16 {
        self.code
    }

    /// Code étendu.
    pub const fn status(&self) -> Option<EnhancedStatus> {
        self.status
    }

    /// Textes des lignes, assainis.
    pub fn lines(&self) -> &[String] {
        &self.lines
    }

    /// Réponse `2yz` ou `3yz`.
    pub const fn is_positive(&self) -> bool {
        self.code < 400
    }

    /// Réponse `4yz` : l'expéditeur réessaiera.
    pub const fn is_transient(&self) -> bool {
        self.code >= 400 && self.code < 500
    }

    /// Réponse `5yz`.
    pub const fn is_permanent(&self) -> bool {
        self.code >= 500
    }

    /// Ajoute la réponse, lignes terminées par CRLF, à `out`.
    pub fn write_to(&self, out: &mut Vec<u8>) {
        let last = self.lines.len().saturating_sub(1);
        for (index, line) in self.lines.iter().enumerate() {
            out.extend_from_slice(self.code.to_string().as_bytes());
            out.push(if index == last { b' ' } else { b'-' });
            if let Some(status) = self.status {
                out.extend_from_slice(status.to_string().as_bytes());
                if !line.is_empty() {
                    out.push(b' ');
                }
            }
            out.extend_from_slice(line.as_bytes());
            out.extend_from_slice(b"\r\n");
        }
    }

    /// Octets de la réponse.
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut out = Vec::new();
        self.write_to(&mut out);
        out
    }

    /// Réponse sur une ligne de texte : code, code étendu, puis le texte des lignes séparé par
    /// des espaces (forme du champ `Diagnostic-Code: smtp;` d'un avis, RFC 3464 §2.3.6, comme
    /// Mox). Texte assaini (ASCII imprimable).
    pub fn diagnostic(&self) -> String {
        let mut out = self.code.to_string();
        if let Some(status) = self.status {
            out.push(' ');
            out.push_str(&status.to_string());
        }
        for line in &self.lines {
            if !line.is_empty() {
                out.push(' ');
                out.push_str(line);
            }
        }
        out
    }
}

/// Extensions annoncées en réponse à `EHLO` : celles de la décision S5 (réception, port 25),
/// plus `DSN` et `AUTH PLAIN LOGIN` pour le dépôt authentifié (lot 6, décisions E14 et E22).
/// `BINARYMIME`, `REQUIRETLS` (décision E26) et les autres ne sont jamais annoncées.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct Extensions {
    /// `PIPELINING` (RFC 2920).
    pub pipelining: bool,
    /// `SIZE <max>` (RFC 1870) : taille maximale d'un message, en octets.
    pub size: Option<u64>,
    /// `8BITMIME` (RFC 6152).
    pub eight_bit_mime: bool,
    /// `SMTPUTF8` (RFC 6531).
    pub smtputf8: bool,
    /// `ENHANCEDSTATUSCODES` (RFC 2034).
    pub enhanced_status_codes: bool,
    /// `STARTTLS` (RFC 3207) : seulement sur une écoute `starttls` avec un certificat chargé,
    /// et jamais une fois la session chiffrée.
    pub starttls: bool,
    /// `CHUNKING` (RFC 3030, commande `BDAT`).
    pub chunking: bool,
    /// `DSN` (RFC 3461) : paramètres `RET`, `ENVID`, `NOTIFY` et `ORCPT` acceptés. Dépôt
    /// authentifié seulement (décision E22) ; jamais sur le port 25.
    pub dsn: bool,
    /// `AUTH PLAIN LOGIN` (RFC 4954) : dépôt authentifié seulement, et seulement sur une session
    /// chiffrée (décision E14).
    pub auth: bool,
}

impl Extensions {
    /// Extensions de la réception SMTP (décision S5) : toutes, `STARTTLS` selon l'écoute ; ni
    /// `DSN` ni `AUTH`.
    pub const fn inbound(max_message_bytes: u64, starttls: bool) -> Self {
        Self {
            pipelining: true,
            size: Some(max_message_bytes),
            eight_bit_mime: true,
            smtputf8: true,
            enhanced_status_codes: true,
            starttls,
            chunking: true,
            dsn: false,
            auth: false,
        }
    }

    /// Extensions du dépôt authentifié (ports 587 et 465, décisions E14 et E22) : celles de la
    /// réception, plus `DSN` ; `STARTTLS` selon l'écoute, `AUTH` quand la session est chiffrée.
    pub const fn submission(max_message_bytes: u64, starttls: bool, auth: bool) -> Self {
        let mut extensions = Self::inbound(max_message_bytes, starttls);
        extensions.dsn = true;
        extensions.auth = auth;
        extensions
    }

    fn keywords(&self) -> Vec<String> {
        let mut keywords = Vec::with_capacity(9);
        if self.pipelining {
            keywords.push("PIPELINING".to_owned());
        }
        if let Some(size) = self.size {
            keywords.push(format!("SIZE {size}"));
        }
        if self.eight_bit_mime {
            keywords.push("8BITMIME".to_owned());
        }
        if self.smtputf8 {
            keywords.push("SMTPUTF8".to_owned());
        }
        if self.enhanced_status_codes {
            keywords.push("ENHANCEDSTATUSCODES".to_owned());
        }
        if self.starttls {
            keywords.push("STARTTLS".to_owned());
        }
        if self.chunking {
            keywords.push("CHUNKING".to_owned());
        }
        if self.dsn {
            keywords.push("DSN".to_owned());
        }
        if self.auth {
            keywords.push("AUTH PLAIN LOGIN".to_owned());
        }
        keywords
    }
}

/// Réponse `250` à `EHLO` : nom de l'hôte puis une extension par ligne (RFC 5321 §4.1.1.1).
/// Aucun code étendu (RFC 2034 §3).
pub fn ehlo_response(hostname: &str, extensions: &Extensions) -> Result<Response, ResponseError> {
    check_hostname(hostname)?;
    let mut lines = vec![hostname.to_owned()];
    lines.extend(extensions.keywords());
    Response::with_lines(250, None, lines)
}

/// Réponse `250` à `HELO` : nom de l'hôte seul.
pub fn helo_response(hostname: &str) -> Result<Response, ResponseError> {
    check_hostname(hostname)?;
    Response::new(250, None, hostname)
}

fn check_code(code: u16, status: Option<EnhancedStatus>) -> Result<(), ResponseError> {
    if !(200..=599).contains(&code) || (code / 10) % 10 > 5 {
        return Err(ResponseError::InvalidCode);
    }
    if let Some(status) = status {
        if u16::from(status.class) != code / 100 {
            return Err(ResponseError::StatusMismatch);
        }
    }
    Ok(())
}

fn check_hostname(hostname: &str) -> Result<(), ResponseError> {
    let valid = !hostname.is_empty()
        && hostname.len() <= 255
        && hostname.split('.').all(|label| {
            !label.is_empty()
                && label.len() <= 63
                && label
                    .bytes()
                    .all(|b| b.is_ascii_alphanumeric() || b == b'-')
                && !label.starts_with('-')
                && !label.ends_with('-')
        });
    if valid {
        Ok(())
    } else {
        Err(ResponseError::InvalidHostname)
    }
}

/// Longueur de `ddd-` et du code étendu suivi d'une espace.
fn prefix_len(status: Option<EnhancedStatus>) -> usize {
    4 + status.map_or(0, |status| status.to_string().len() + 1)
}

/// ASCII imprimable seulement ; tout autre caractère devient `?` ; coupe à `max` octets.
fn sanitize(text: &str, max: usize) -> String {
    text.chars()
        .map(|ch| if (' '..='~').contains(&ch) { ch } else { '?' })
        .take(max)
        .collect()
}
