// SPDX-License-Identifier: AGPL-3.0-only

//! Chemins et boîtes aux lettres de l'enveloppe SMTP (RFC 5321 §4.1.2, RFC 6531 §3.3).
//!
//! Écrit pour Lyxal OS sur le modèle de Mox (`smtpserver/parse.go`, MIT) : lecture stricte de la
//! grammaire, aucune conversion avec perte (UTF-8 invalide refusé par l'appelant), route source
//! lue puis signalée (aucun relais). La conversion d'un domaine Unicode en forme ASCII
//! (A-label) n'est pas faite ici : elle appartient à `lyxal_mail` (décision S16).

use std::fmt;
use std::net::{Ipv4Addr, Ipv6Addr};

/// Longueur maximale d'un chemin, chevrons compris (RFC 5321 §4.5.3.1.3).
pub const MAX_PATH_BYTES: usize = 256;
/// Longueur maximale d'un domaine (RFC 5321 §4.5.3.1.2).
pub const MAX_DOMAIN_BYTES: usize = 255;
/// Longueur maximale d'une étiquette ASCII d'un domaine (RFC 1035 §2.3.4).
pub const MAX_LABEL_BYTES: usize = 63;
/// Longueur maximale d'une partie locale. La RFC 5321 (§4.5.3.1.1) fixe 64 octets mais demande
/// de tolérer davantage ; les adresses de retour engendrées (SRS, VERP) dépassent souvent 64.
/// 128 comme Mox hors mode pédant.
pub const MAX_LOCAL_PART_BYTES: usize = 128;

/// Partie droite d'une boîte aux lettres, ou argument de `EHLO` / `HELO`.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Domain {
    /// Nom de domaine tel que reçu (casse gardée) ; étiquettes Unicode (U-label) permises,
    /// voir [`Domain::is_ascii`].
    Name(String),
    /// Adresse littérale IPv4 (`[192.0.2.1]`).
    Ipv4(Ipv4Addr),
    /// Adresse littérale IPv6 (`[IPv6:2001:db8::1]`).
    Ipv6(Ipv6Addr),
}

impl Domain {
    /// Vrai si le domaine ne contient que des caractères ASCII (toujours vrai pour une adresse
    /// littérale).
    pub fn is_ascii(&self) -> bool {
        match self {
            Domain::Name(name) => name.is_ascii(),
            Domain::Ipv4(_) | Domain::Ipv6(_) => true,
        }
    }

    /// Vrai pour une adresse littérale (`[...]`).
    pub fn is_address_literal(&self) -> bool {
        !matches!(self, Domain::Name(_))
    }
}

impl fmt::Display for Domain {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Domain::Name(name) => f.write_str(name),
            Domain::Ipv4(ip) => write!(f, "[{ip}]"),
            Domain::Ipv6(ip) => write!(f, "[IPv6:{ip}]"),
        }
    }
}

/// Boîte aux lettres `partie-locale@domaine`.
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct Mailbox {
    local_part: String,
    domain: Domain,
}

impl Mailbox {
    /// Partie locale décodée (guillemets et barres obliques inverses d'une chaîne entre
    /// guillemets retirés), casse gardée.
    pub fn local_part(&self) -> &str {
        &self.local_part
    }

    /// Domaine ou adresse littérale.
    pub fn domain(&self) -> &Domain {
        &self.domain
    }

    /// Vrai si la boîte ne contient que des caractères ASCII. Une boîte non ASCII n'est permise
    /// que dans une transaction ouverte avec `SMTPUTF8` (RFC 6531 §3.4).
    pub fn is_ascii(&self) -> bool {
        self.local_part.is_ascii() && self.domain.is_ascii()
    }
}

impl fmt::Display for Mailbox {
    /// Forme de l'enveloppe : la partie locale est remise entre guillemets si elle n'est pas
    /// une suite d'atomes séparés par des points.
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if is_dot_string(&self.local_part) {
            f.write_str(&self.local_part)?;
        } else {
            f.write_str("\"")?;
            for ch in self.local_part.chars() {
                if ch == '"' || ch == '\\' {
                    f.write_str("\\")?;
                }
                write!(f, "{ch}")?;
            }
            f.write_str("\"")?;
        }
        write!(f, "@{}", self.domain)
    }
}

/// Chemin de retour de `MAIL FROM` (RFC 5321 §4.1.2 `Reverse-path`).
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum ReversePath {
    /// Chemin vide `<>` (avis de non-remise, RFC 5321 §4.5.5).
    Null,
    /// Expéditeur.
    Mailbox(Mailbox),
}

impl ReversePath {
    /// Vrai si le chemin ne contient que des caractères ASCII.
    pub fn is_ascii(&self) -> bool {
        match self {
            ReversePath::Null => true,
            ReversePath::Mailbox(mailbox) => mailbox.is_ascii(),
        }
    }
}

/// Chemin d'un destinataire de `RCPT TO` (RFC 5321 §4.1.2 `Forward-path`).
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum ForwardPath {
    /// `<Postmaster>` sans domaine (RFC 5321 §4.1.1.3, §4.5.1), sans égard à la casse.
    Postmaster,
    /// Destinataire.
    Mailbox(Mailbox),
}

impl ForwardPath {
    /// Vrai si le chemin ne contient que des caractères ASCII.
    pub fn is_ascii(&self) -> bool {
        match self {
            ForwardPath::Postmaster => true,
            ForwardPath::Mailbox(mailbox) => mailbox.is_ascii(),
        }
    }
}

/// Chemin lu et reste de la ligne.
pub(crate) struct ParsedPath<'a, T> {
    pub path: T,
    /// Une route source (`@a,@b:`) précédait la boîte ; elle est lue puis ignorée
    /// (RFC 5321 §4.1.1.3, annexe C), et signalée à la session (relais refusé, plan §7.3).
    pub source_route: bool,
    pub rest: &'a str,
}

/// Lit `<chemin>` au début de `input` pour `MAIL FROM`.
pub(crate) fn parse_reverse_path(input: &str) -> Option<ParsedPath<'_, ReversePath>> {
    let inner_start = input.strip_prefix('<')?;
    if let Some(rest) = inner_start.strip_prefix('>') {
        return Some(ParsedPath {
            path: ReversePath::Null,
            source_route: false,
            rest,
        });
    }
    let parsed = parse_path(input)?;
    Some(ParsedPath {
        path: ReversePath::Mailbox(parsed.path),
        source_route: parsed.source_route,
        rest: parsed.rest,
    })
}

/// Lit `<chemin>` au début de `input` pour `RCPT TO`.
pub(crate) fn parse_forward_path(input: &str) -> Option<ParsedPath<'_, ForwardPath>> {
    const POSTMASTER: &str = "<postmaster>";
    if let Some(head) = input.get(..POSTMASTER.len()) {
        if head.eq_ignore_ascii_case(POSTMASTER) {
            return Some(ParsedPath {
                path: ForwardPath::Postmaster,
                source_route: false,
                rest: &input[POSTMASTER.len()..],
            });
        }
    }
    let parsed = parse_path(input)?;
    Some(ParsedPath {
        path: ForwardPath::Mailbox(parsed.path),
        source_route: parsed.source_route,
        rest: parsed.rest,
    })
}

/// `Path = "<" [ A-d-l ":" ] Mailbox ">"`.
fn parse_path(input: &str) -> Option<ParsedPath<'_, Mailbox>> {
    let mut cursor = input.strip_prefix('<')?;
    let mut source_route = false;
    if cursor.starts_with('@') {
        // A-d-l = At-domain *( "," At-domain ) ; At-domain = "@" Domain
        loop {
            let after_at = cursor.strip_prefix('@')?;
            let (_, rest) = parse_domain_name(after_at)?;
            if let Some(rest) = rest.strip_prefix(',') {
                cursor = rest;
                continue;
            }
            cursor = rest.strip_prefix(':')?;
            break;
        }
        source_route = true;
    }
    let (mailbox, rest) = parse_mailbox(cursor)?;
    let rest = rest.strip_prefix('>')?;
    if input.len() - rest.len() > MAX_PATH_BYTES {
        return None;
    }
    Some(ParsedPath {
        path: mailbox,
        source_route,
        rest,
    })
}

/// `Mailbox = Local-part "@" ( Domain / address-literal )`.
fn parse_mailbox(input: &str) -> Option<(Mailbox, &str)> {
    let (local_part, rest) = parse_local_part(input)?;
    let rest = rest.strip_prefix('@')?;
    let (domain, rest) = parse_domain_or_literal(rest)?;
    Some((Mailbox { local_part, domain }, rest))
}

/// `Local-part = Dot-string / Quoted-string` (UTF-8 permis, RFC 6531 §3.3).
fn parse_local_part(input: &str) -> Option<(String, &str)> {
    let (local_part, rest) = if let Some(quoted) = input.strip_prefix('"') {
        parse_quoted_string(quoted)?
    } else {
        let end = input
            .find(|ch: char| !(is_atext(ch) || ch == '.'))
            .unwrap_or(input.len());
        let candidate = &input[..end];
        if !is_dot_string(candidate) {
            return None;
        }
        (candidate.to_owned(), &input[end..])
    };
    if local_part.is_empty() && !input.starts_with('"') {
        return None;
    }
    if local_part.len() > MAX_LOCAL_PART_BYTES {
        return None;
    }
    Some((local_part, rest))
}

/// Contenu d'une `Quoted-string` après le guillemet ouvrant ; rend le contenu décodé et le
/// reste après le guillemet fermant.
fn parse_quoted_string(input: &str) -> Option<(String, &str)> {
    let mut value = String::new();
    let mut chars = input.char_indices();
    while let Some((index, ch)) = chars.next() {
        match ch {
            '"' => return Some((value, &input[index + 1..])),
            '\\' => {
                // quoted-pairSMTP = %d92 %d32-126
                let (_, escaped) = chars.next()?;
                if !(' '..='~').contains(&escaped) {
                    return None;
                }
                value.push(escaped);
            }
            // qtextSMTP = %d32-33 / %d35-91 / %d93-126 / UTF8-non-ascii
            ' '..='~' => value.push(ch),
            _ if !ch.is_ascii() && !ch.is_control() => value.push(ch),
            _ => return None,
        }
        if value.len() > MAX_LOCAL_PART_BYTES {
            return None;
        }
    }
    None
}

/// `Dot-string = Atom *("." Atom)`.
fn is_dot_string(value: &str) -> bool {
    !value.is_empty()
        && value
            .split('.')
            .all(|atom| !atom.is_empty() && atom.chars().all(is_atext))
}

/// `atext` (RFC 5322 §3.2.3) étendu à l'UTF-8 hors ASCII (RFC 6532 §3.2), sans caractère de
/// commande.
fn is_atext(ch: char) -> bool {
    ch.is_ascii_alphanumeric()
        || matches!(
            ch,
            '!' | '#'
                | '$'
                | '%'
                | '&'
                | '\''
                | '*'
                | '+'
                | '-'
                | '/'
                | '='
                | '?'
                | '^'
                | '_'
                | '`'
                | '{'
                | '|'
                | '}'
                | '~'
        )
        || (!ch.is_ascii() && !ch.is_control())
}

/// Domaine ou adresse littérale au début de `input` (argument de `EHLO`, partie droite d'une
/// boîte).
pub(crate) fn parse_domain_or_literal(input: &str) -> Option<(Domain, &str)> {
    if let Some(literal) = input.strip_prefix('[') {
        let end = literal.find(']')?;
        let content = &literal[..end];
        let rest = &literal[end + 1..];
        let domain = if let Some(ipv6) = strip_prefix_ignore_case(content, "IPv6:") {
            Domain::Ipv6(ipv6.parse().ok()?)
        } else {
            Domain::Ipv4(content.parse().ok()?)
        };
        return Some((domain, rest));
    }
    let (name, rest) = parse_domain_name(input)?;
    Some((Domain::Name(name.to_owned()), rest))
}

/// `Domain = sub-domain *("." sub-domain)` ; `sub-domain = Let-dig [Ldh-str]` ou U-label
/// (RFC 6531 §3.3). Rend le nom et le reste.
fn parse_domain_name(input: &str) -> Option<(&str, &str)> {
    let end = input
        .find(|ch: char| {
            !(ch.is_ascii_alphanumeric() || ch == '-' || ch == '.' || is_utf8_label_char(ch))
        })
        .unwrap_or(input.len());
    let name = &input[..end];
    if name.is_empty() || name.len() > MAX_DOMAIN_BYTES {
        return None;
    }
    for label in name.split('.') {
        let first = label.chars().next()?;
        let last = label.chars().next_back()?;
        if first == '-' || last == '-' {
            return None;
        }
        if label.is_ascii() && label.len() > MAX_LABEL_BYTES {
            return None;
        }
    }
    Some((name, &input[end..]))
}

fn is_utf8_label_char(ch: char) -> bool {
    !ch.is_ascii() && !ch.is_control() && !ch.is_whitespace()
}

fn strip_prefix_ignore_case<'a>(value: &'a str, prefix: &str) -> Option<&'a str> {
    let head = value.get(..prefix.len())?;
    head.eq_ignore_ascii_case(prefix)
        .then(|| &value[prefix.len()..])
}
