// SPDX-License-Identifier: AGPL-3.0-only

//! Lecture d'un enregistrement SPF (RFC 7208 §4.5, §5, §6, §7.1), écrite depuis la RFC.
//! Toute erreur de syntaxe, n'importe où dans l'enregistrement, rend `permerror` avant toute
//! évaluation (§4.6).

use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};

/// Nombre maximal de termes lus dans un enregistrement.
const MAX_TERMS: usize = 256;
/// Valeur maximale d'un chiffre de transformation de macro (§7.3 : au moins 128 acceptés).
const MAX_MACRO_DIGITS: u32 = 128;

/// Qualificatif d'une directive (§4.6.2).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) enum Qualifier {
    Pass,
    Fail,
    SoftFail,
    Neutral,
}

/// Morceau d'une chaîne à macros (§7.1).
#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) enum MacroToken {
    /// Texte recopié tel quel (`%%`, `%_`, `%-` déjà traduits).
    Literal(String),
    /// `%{lettre chiffres r délimiteurs}`.
    Macro {
        letter: u8,
        url_escape: bool,
        digits: Option<u32>,
        reverse: bool,
        delimiters: Vec<u8>,
    },
}

/// Chaîne à macros (`domain-spec` d'un mécanisme ou valeur d'un modificateur).
#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct MacroString(pub(crate) Vec<MacroToken>);

/// Mécanisme (§5).
#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) enum Mechanism {
    All,
    Include(MacroString),
    A {
        domain: Option<MacroString>,
        prefix4: u8,
        prefix6: u8,
    },
    Mx {
        domain: Option<MacroString>,
        prefix4: u8,
        prefix6: u8,
    },
    Ptr(Option<MacroString>),
    Ip4 {
        network: Ipv4Addr,
        prefix: u8,
    },
    Ip6 {
        network: Ipv6Addr,
        prefix: u8,
    },
    Exists(MacroString),
}

/// Directive : qualificatif et mécanisme.
#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct Directive {
    pub(crate) qualifier: Qualifier,
    pub(crate) mechanism: Mechanism,
}

/// Enregistrement lu. `exp=` est lu (syntaxe contrôlée) mais jamais utilisé : aucun texte
/// d'explication n'est renvoyé au client (plan du lot 5, §6).
#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct SpfRecord {
    pub(crate) directives: Vec<Directive>,
    pub(crate) redirect: Option<MacroString>,
}

/// Enregistrement illisible.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub(crate) struct SyntaxError;

/// Vrai si le texte TXT est un enregistrement SPF (§4.5 : `v=spf1` suivi d'une espace ou de la
/// fin, casse ignorée).
pub(crate) fn is_spf_record(txt: &str) -> bool {
    let bytes = txt.as_bytes();
    bytes.len() >= 6
        && bytes
            .get(..6)
            .is_some_and(|start| start.eq_ignore_ascii_case(b"v=spf1"))
        && bytes.get(6).is_none_or(|byte| *byte == b' ')
}

impl SpfRecord {
    /// Lit un enregistrement dont [`is_spf_record`] est vrai.
    pub(crate) fn parse(txt: &str) -> Result<Self, SyntaxError> {
        if !is_spf_record(txt) {
            return Err(SyntaxError);
        }
        let mut record = Self {
            directives: Vec::new(),
            redirect: None,
        };
        let mut seen_exp = false;
        let mut terms = 0usize;
        for term in txt.get(6..).unwrap_or_default().split(' ') {
            if term.is_empty() {
                continue;
            }
            terms += 1;
            if terms > MAX_TERMS {
                return Err(SyntaxError);
            }
            if let Some((name, value)) = split_modifier(term) {
                if name.eq_ignore_ascii_case("redirect") {
                    if record.redirect.is_some() {
                        return Err(SyntaxError);
                    }
                    record.redirect = Some(parse_macro_string(value, false)?);
                } else if name.eq_ignore_ascii_case("exp") {
                    if seen_exp {
                        return Err(SyntaxError);
                    }
                    seen_exp = true;
                    parse_macro_string(value, false)?;
                } else {
                    // Modificateur inconnu : ignoré, mais sa syntaxe doit être valide (§6).
                    parse_macro_string(value, true)?;
                }
                continue;
            }
            record.directives.push(parse_directive(term)?);
        }
        Ok(record)
    }

    /// Vrai si l'enregistrement contient un mécanisme `all` (un `redirect=` est alors ignoré,
    /// §6.1).
    pub(crate) fn has_all(&self) -> bool {
        self.directives
            .iter()
            .any(|directive| directive.mechanism == Mechanism::All)
    }
}

/// `nom=valeur` si le terme est un modificateur (§4.6.1 : `name = ALPHA *( ALPHA / DIGIT / "-"
/// / "_" / "." )`, le `=` venant avant tout `:` ou `/`).
fn split_modifier(term: &str) -> Option<(&str, &str)> {
    let index = term.find(['=', ':', '/'])?;
    if term.as_bytes().get(index) != Some(&b'=') {
        return None;
    }
    let name = term.get(..index)?;
    let mut bytes = name.bytes();
    let first_alpha = bytes.next().is_some_and(|byte| byte.is_ascii_alphabetic());
    let rest_valid = bytes.all(|byte| byte.is_ascii_alphanumeric() || b"-_.".contains(&byte));
    (first_alpha && rest_valid).then(|| (name, term.get(index + 1..).unwrap_or_default()))
}

fn parse_directive(term: &str) -> Result<Directive, SyntaxError> {
    let (qualifier, rest) = match term.as_bytes().first() {
        Some(b'+') => (Qualifier::Pass, term.get(1..).unwrap_or_default()),
        Some(b'-') => (Qualifier::Fail, term.get(1..).unwrap_or_default()),
        Some(b'~') => (Qualifier::SoftFail, term.get(1..).unwrap_or_default()),
        Some(b'?') => (Qualifier::Neutral, term.get(1..).unwrap_or_default()),
        _ => (Qualifier::Pass, term),
    };
    let name_end = rest.find([':', '/']).unwrap_or(rest.len());
    let name = rest
        .get(..name_end)
        .unwrap_or_default()
        .to_ascii_lowercase();
    let argument = rest.get(name_end..).unwrap_or_default();
    let mechanism = match name.as_str() {
        "all" if argument.is_empty() => Mechanism::All,
        "include" => Mechanism::Include(required_domain(argument)?),
        "exists" => Mechanism::Exists(required_domain(argument)?),
        "a" | "mx" => {
            let (domain, prefix4, prefix6) = domain_and_cidr(argument)?;
            if name == "a" {
                Mechanism::A {
                    domain,
                    prefix4,
                    prefix6,
                }
            } else {
                Mechanism::Mx {
                    domain,
                    prefix4,
                    prefix6,
                }
            }
        }
        "ptr" => Mechanism::Ptr(if argument.is_empty() {
            None
        } else {
            Some(required_domain(argument)?)
        }),
        "ip4" => {
            let value = argument.strip_prefix(':').ok_or(SyntaxError)?;
            let (address, prefix) = split_prefix(value, 32)?;
            Mechanism::Ip4 {
                network: address.parse().map_err(|_| SyntaxError)?,
                prefix,
            }
        }
        "ip6" => {
            let value = argument.strip_prefix(':').ok_or(SyntaxError)?;
            let (address, prefix) = split_prefix(value, 128)?;
            Mechanism::Ip6 {
                network: address.parse().map_err(|_| SyntaxError)?,
                prefix,
            }
        }
        _ => return Err(SyntaxError),
    };
    Ok(Directive {
        qualifier,
        mechanism,
    })
}

/// `:domain-spec` obligatoire.
fn required_domain(argument: &str) -> Result<MacroString, SyntaxError> {
    let value = argument.strip_prefix(':').ok_or(SyntaxError)?;
    if value.is_empty() {
        return Err(SyntaxError);
    }
    parse_macro_string(value, false)
}

/// `[":" domain-spec] [ dual-cidr-length ]` de `a` et `mx` (§5.3, §5.4, §5.6).
fn domain_and_cidr(argument: &str) -> Result<(Option<MacroString>, u8, u8), SyntaxError> {
    let (domain_part, cidr) = match argument.strip_prefix(':') {
        Some(value) => {
            let cut = first_slash_outside_macro(value).unwrap_or(value.len());
            (
                Some(value.get(..cut).unwrap_or_default()),
                value.get(cut..).unwrap_or_default(),
            )
        }
        None => (None, argument),
    };
    let domain = match domain_part {
        Some("") => return Err(SyntaxError),
        Some(value) => Some(parse_macro_string(value, false)?),
        None => None,
    };
    let (prefix4, prefix6) = parse_dual_cidr(cidr)?;
    Ok((domain, prefix4, prefix6))
}

fn first_slash_outside_macro(value: &str) -> Option<usize> {
    let bytes = value.as_bytes();
    let mut index = 0;
    while let Some(byte) = bytes.get(index) {
        match byte {
            b'%' if bytes.get(index + 1) == Some(&b'{') => {
                index += bytes
                    .get(index..)
                    .and_then(|rest| rest.iter().position(|byte| *byte == b'}'))
                    .unwrap_or(bytes.len());
            }
            b'%' => index += 1,
            b'/' => return Some(index),
            _ => {}
        }
        index += 1;
    }
    None
}

/// `["/" ip4-cidr] ["//" ip6-cidr]`.
fn parse_dual_cidr(cidr: &str) -> Result<(u8, u8), SyntaxError> {
    if cidr.is_empty() {
        return Ok((32, 128));
    }
    if let Some(v6) = cidr.strip_prefix("//") {
        return Ok((32, parse_length(v6, 128)?));
    }
    let v4 = cidr.strip_prefix('/').ok_or(SyntaxError)?;
    match v4.split_once("//") {
        Some((v4, v6)) => Ok((parse_length(v4, 32)?, parse_length(v6, 128)?)),
        None => Ok((parse_length(v4, 32)?, 128)),
    }
}

fn split_prefix(value: &str, max: u8) -> Result<(&str, u8), SyntaxError> {
    match value.split_once('/') {
        Some((address, length)) => Ok((address, parse_length(length, max)?)),
        None => Ok((value, max)),
    }
}

/// Longueur de préfixe sans zéro de tête (`"0" / %x31-39 0*2DIGIT`), au plus `max`.
fn parse_length(text: &str, max: u8) -> Result<u8, SyntaxError> {
    if text.is_empty()
        || text.len() > 3
        || !text.bytes().all(|byte| byte.is_ascii_digit())
        || (text.len() > 1 && text.starts_with('0'))
    {
        return Err(SyntaxError);
    }
    let value: u8 = text.parse().map_err(|_| SyntaxError)?;
    if value > max {
        return Err(SyntaxError);
    }
    Ok(value)
}

/// Lit une chaîne à macros (§7.1). `explanation` : lettres `c`, `r`, `t` permises (texte
/// d'explication et modificateurs inconnus seulement).
pub(crate) fn parse_macro_string(
    value: &str,
    explanation: bool,
) -> Result<MacroString, SyntaxError> {
    let bytes = value.as_bytes();
    let mut tokens = Vec::new();
    let mut literal = String::new();
    let mut index = 0;
    while let Some(&byte) = bytes.get(index) {
        if byte != b'%' {
            // macro-literal : %x21-24 / %x26-7E.
            if !(0x21..=0x7e).contains(&byte) {
                return Err(SyntaxError);
            }
            literal.push(char::from(byte));
            index += 1;
            continue;
        }
        match bytes.get(index + 1) {
            Some(b'%') => literal.push('%'),
            Some(b'_') => literal.push(' '),
            Some(b'-') => literal.push_str("%20"),
            Some(b'{') => {
                let close = bytes
                    .get(index + 2..)
                    .and_then(|rest| rest.iter().position(|byte| *byte == b'}'))
                    .ok_or(SyntaxError)?;
                let inner = bytes.get(index + 2..index + 2 + close).ok_or(SyntaxError)?;
                if !literal.is_empty() {
                    tokens.push(MacroToken::Literal(std::mem::take(&mut literal)));
                }
                tokens.push(parse_macro(inner, explanation)?);
                index += 2 + close + 1;
                continue;
            }
            _ => return Err(SyntaxError),
        }
        index += 2;
    }
    if !literal.is_empty() {
        tokens.push(MacroToken::Literal(literal));
    }
    Ok(MacroString(tokens))
}

fn parse_macro(inner: &[u8], explanation: bool) -> Result<MacroToken, SyntaxError> {
    let (&letter, mut rest) = inner.split_first().ok_or(SyntaxError)?;
    let lower = letter.to_ascii_lowercase();
    let allowed: &[u8] = if explanation {
        b"slodiphvcrt"
    } else {
        b"slodiphv"
    };
    if !allowed.contains(&lower) {
        return Err(SyntaxError);
    }
    let digit_count = rest.iter().take_while(|byte| byte.is_ascii_digit()).count();
    let digits = if digit_count == 0 {
        None
    } else {
        let text = std::str::from_utf8(rest.get(..digit_count).unwrap_or_default())
            .map_err(|_| SyntaxError)?;
        let value: u32 = text.parse().map_err(|_| SyntaxError)?;
        if value == 0 || value > MAX_MACRO_DIGITS {
            return Err(SyntaxError);
        }
        rest = rest.get(digit_count..).unwrap_or_default();
        Some(value)
    };
    let reverse = matches!(rest.first(), Some(b'r' | b'R'));
    if reverse {
        rest = rest.get(1..).unwrap_or_default();
    }
    if !rest.iter().all(|byte| b".-+,/_=".contains(byte)) {
        return Err(SyntaxError);
    }
    Ok(MacroToken::Macro {
        letter: lower,
        url_escape: letter.is_ascii_uppercase(),
        digits,
        reverse,
        delimiters: rest.to_vec(),
    })
}

/// Vrai si `ip` appartient au réseau `network/prefix` de même famille.
pub(crate) fn in_network(ip: IpAddr, network: IpAddr, prefix: u8) -> bool {
    match (ip, network) {
        (IpAddr::V4(ip), IpAddr::V4(network)) => {
            let mask = u32::MAX
                .checked_shl(32 - u32::from(prefix.min(32)))
                .unwrap_or(0);
            u32::from(ip) & mask == u32::from(network) & mask
        }
        (IpAddr::V6(ip), IpAddr::V6(network)) => {
            let mask = u128::MAX
                .checked_shl(128 - u32::from(prefix.min(128)))
                .unwrap_or(0);
            u128::from(ip) & mask == u128::from(network) & mask
        }
        _ => false,
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn reconnaissance() {
        assert!(is_spf_record("v=spf1"));
        assert!(is_spf_record("V=SPF1 -all"));
        assert!(!is_spf_record("v=spf10"));
        assert!(!is_spf_record("something else"));
    }

    #[test]
    fn lecture() {
        let record = SpfRecord::parse(
            "v=spf1 a mx/30 mx:example.org/30//64 ptr ~ip4:192.0.2.0/24 ?ip6:2001:db8::/32 \
             -include:_spf.example.com exists:%{ir}.%{l1r+}.%{d} redirect=_spf.example.com x-foo=bar",
        )
        .unwrap();
        assert_eq!(record.directives.len(), 8);
        assert_eq!(
            record.directives[2].mechanism,
            Mechanism::Mx {
                domain: Some(MacroString(vec![MacroToken::Literal("example.org".into())])),
                prefix4: 30,
                prefix6: 64,
            }
        );
        assert_eq!(record.directives[4].qualifier, Qualifier::SoftFail);
        assert!(record.redirect.is_some());
        assert!(!record.has_all());
    }

    #[test]
    fn refus_de_syntaxe() {
        for text in [
            "v=spf1 !",
            "v=spf1 foo",
            "v=spf1 all:x",
            "v=spf1 include",
            "v=spf1 include:",
            "v=spf1 ip4:300.0.0.1",
            "v=spf1 ip4:192.0.2.0/33",
            "v=spf1 ip4:192.0.2.0/024",
            "v=spf1 ip6:zz::1",
            "v=spf1 a/",
            "v=spf1 redirect=a.example redirect=b.example",
            "v=spf1 exp=a.example exp=b.example",
            "v=spf1 include:%{c}",
            "v=spf1 a:%{s0}",
            "v=spf1 a:%{s999}",
            "v=spf1 a:%{x}",
            "v=spf1 a:%{s",
            "v=spf1 a:%b",
            "v=spf1 a:%",
        ] {
            assert_eq!(SpfRecord::parse(text), Err(SyntaxError), "{text}");
        }
        // Lettres `c`, `r`, `t` permises dans `exp=` comme dans un modificateur inconnu ?
        // Non pour `exp=` (domain-spec), oui pour un modificateur inconnu (macro-string).
        assert!(SpfRecord::parse("v=spf1 x-unknown=%{c}").is_ok());
        assert!(SpfRecord::parse("v=spf1 exp=%{c}").is_err());
    }

    #[test]
    fn reseaux() {
        let ip = |text: &str| text.parse::<IpAddr>().unwrap();
        assert!(in_network(ip("192.0.2.129"), ip("192.0.2.128"), 28));
        assert!(!in_network(ip("192.0.2.144"), ip("192.0.2.128"), 28));
        assert!(in_network(ip("10.0.0.1"), ip("0.0.0.0"), 0));
        assert!(in_network(ip("2001:db8::1"), ip("2001:db8::"), 64));
        assert!(!in_network(ip("2001:db9::1"), ip("2001:db8::"), 32));
        assert!(!in_network(ip("192.0.2.1"), ip("2001:db8::"), 0));
    }
}
