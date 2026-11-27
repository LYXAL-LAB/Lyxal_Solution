// SPDX-License-Identifier: AGPL-3.0-only

//! Codages des valeurs de DSN : `xtext` (RFC 3461 §4, paramètres `ENVID`, `ORCPT` et `AUTH=`
//! de la RFC 4954 §5) et adresses internationales `utf-8-addr-xtext` / `utf-8-addr-unitext`
//! (RFC 6533 §3).
//!
//! Écrit pour Lyxal OS sur le modèle de Mox (`dsn/parse.go`, `parseAddress` : séquences
//! `\x{...}`). Grammaire :
//!
//! ```text
//! xtext      = *( xchar / hexchar )
//! xchar      = %x21-2A / %x2C-3C / %x3E-7E      ; ASCII imprimable sauf "+" et "="
//! hexchar    = "+" 2( %x30-39 / %x41-46 )      ; octet en hexadécimal majuscule
//!
//! utf-8-addr-xtext   = 1*( QCHAR / EmbeddedUnicodeChar )
//! utf-8-addr-unitext = 1*( QUCHAR / EmbeddedUnicodeChar )
//! QCHAR              = %x21-2A / %x2C-3C / %x3E-5B / %x5D-7E   ; sans "+", "=", "\"
//! QUCHAR             = QCHAR / UTF8-non-ascii
//! EmbeddedUnicodeChar = %x5C.78 "{" 2*6HEXDIG "}"            ; \x{HEXPOINT}
//! ```

use std::fmt::Write as _;

/// Longueur maximale d'un point de code `\x{...}` (RFC 6533 §3 : 2 à 6 chiffres).
const MAX_HEXPOINT_DIGITS: usize = 6;

/// `xchar` : ASCII imprimable sauf `+` et `=`.
const fn is_xchar(byte: u8) -> bool {
    matches!(byte, b'!'..=b'~') && byte != b'+' && byte != b'='
}

/// `QCHAR` de la RFC 6533 : ASCII imprimable sauf `+`, `=` et `\`.
const fn is_qchar(byte: u8) -> bool {
    is_xchar(byte) && byte != b'\\'
}

/// Vrai si `value` est un `xtext` valide (hexadécimal en majuscules, comme la grammaire).
pub fn is_xtext(value: &str) -> bool {
    let bytes = value.as_bytes();
    let mut index = 0;
    while index < bytes.len() {
        match bytes[index] {
            b'+' => {
                let hex = bytes.get(index + 1..index + 3);
                if !hex
                    .is_some_and(|hex| hex.iter().all(|b| matches!(b, b'0'..=b'9' | b'A'..=b'F')))
                {
                    return false;
                }
                index += 3;
            }
            byte if is_xchar(byte) => index += 1,
            _ => return false,
        }
    }
    true
}

/// Code des octets en `xtext` : un octet hors `xchar` devient `+HH`.
pub fn encode_xtext(value: &[u8]) -> String {
    let mut out = String::with_capacity(value.len());
    for &byte in value {
        if is_xchar(byte) {
            out.push(char::from(byte));
        } else {
            // Écrire dans une `String` ne peut pas échouer.
            let _ = write!(out, "+{byte:02X}");
        }
    }
    out
}

/// Décode un `xtext`. Tolérant à l'hexadécimal en minuscules ; `None` pour un `+` qui n'est
/// pas suivi de deux chiffres hexadécimaux ou pour un caractère hors `xchar`.
pub fn decode_xtext(value: &str) -> Option<Vec<u8>> {
    let bytes = value.as_bytes();
    let mut out = Vec::with_capacity(bytes.len());
    let mut index = 0;
    while index < bytes.len() {
        match bytes[index] {
            b'+' => {
                let high = hex_value(*bytes.get(index + 1)?)?;
                let low = hex_value(*bytes.get(index + 2)?)?;
                out.push(high << 4 | low);
                index += 3;
            }
            byte if is_xchar(byte) => {
                out.push(byte);
                index += 1;
            }
            _ => return None,
        }
    }
    Some(out)
}

/// Code une adresse en `utf-8-addr-xtext` (ASCII seul) : un caractère hors `QCHAR` devient
/// `\x{HEX}`.
pub fn encode_utf8_addr_xtext(address: &str) -> String {
    encode_embedded(address, false)
}

/// Code une adresse en `utf-8-addr-unitext` : caractères non ASCII gardés, caractères ASCII
/// hors `QCHAR` (espace, `+`, `=`, `\`, caractères de commande) en `\x{HEX}`.
pub fn encode_utf8_addr_unitext(address: &str) -> String {
    encode_embedded(address, true)
}

fn encode_embedded(address: &str, keep_non_ascii: bool) -> String {
    let mut out = String::with_capacity(address.len());
    for ch in address.chars() {
        let keep = if ch.is_ascii() {
            is_qchar(ch as u8)
        } else {
            keep_non_ascii && !ch.is_control()
        };
        if keep {
            out.push(ch);
        } else {
            let _ = write!(out, "\\x{{{:02X}}}", u32::from(ch));
        }
    }
    out
}

/// Décode une adresse `utf-8-addr-xtext` ou `utf-8-addr-unitext` (séquences `\x{...}`,
/// caractères non ASCII gardés). Tolérant aux avis réels : `+` et `=` acceptés tels quels.
/// `None` pour une séquence `\x{` mal formée, un point de code invalide, un caractère de
/// commande ou une espace.
pub fn decode_utf8_addr(value: &str) -> Option<String> {
    let mut out = String::with_capacity(value.len());
    let mut chars = value.chars();
    while let Some(ch) = chars.next() {
        if ch == '\\' {
            if chars.next()? != 'x' || chars.next()? != '{' {
                return None;
            }
            let mut point = 0u32;
            let mut digits = 0;
            loop {
                let digit = chars.next()?;
                if digit == '}' {
                    break;
                }
                point = point << 4 | u32::from(hex_value(u8::try_from(digit).ok()?)?);
                digits += 1;
                if digits > MAX_HEXPOINT_DIGITS {
                    return None;
                }
            }
            if digits < 2 {
                return None;
            }
            let decoded = char::from_u32(point)?;
            if decoded.is_control() {
                return None;
            }
            out.push(decoded);
        } else if ch.is_ascii_graphic() || (!ch.is_ascii() && !ch.is_control()) {
            out.push(ch);
        } else {
            return None;
        }
    }
    Some(out)
}

const fn hex_value(byte: u8) -> Option<u8> {
    match byte {
        b'0'..=b'9' => Some(byte - b'0'),
        b'A'..=b'F' => Some(byte - b'A' + 10),
        b'a'..=b'f' => Some(byte - b'a' + 10),
        _ => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn xtext_round_trip() {
        for value in [&b""[..], b"QQ314159", b"a+b=c d", b"\x00\xff\r\n", b"!~"] {
            let encoded = encode_xtext(value);
            assert!(is_xtext(&encoded), "{encoded}");
            assert_eq!(decode_xtext(&encoded).as_deref(), Some(value));
        }
        assert_eq!(encode_xtext(b"a+b=c"), "a+2Bb+3Dc");
        assert_eq!(decode_xtext("a+2bb").as_deref(), Some(&b"a+b"[..]));
        assert_eq!(decode_xtext("+2"), None);
        assert_eq!(decode_xtext("a=b"), None);
        assert_eq!(decode_xtext("é"), None);
        assert!(!is_xtext("+2b"));
    }

    #[test]
    fn utf8_addr_round_trip() {
        let address = "jöran+x@exämple.org";
        let xtext = encode_utf8_addr_xtext(address);
        assert!(xtext.is_ascii());
        assert!(is_xtext(&xtext), "{xtext}");
        assert_eq!(xtext, "j\\x{F6}ran\\x{2B}x@ex\\x{E4}mple.org");
        assert_eq!(decode_utf8_addr(&xtext).as_deref(), Some(address));
        let unitext = encode_utf8_addr_unitext(address);
        assert_eq!(unitext, "jöran\\x{2B}x@exämple.org");
        assert_eq!(decode_utf8_addr(&unitext).as_deref(), Some(address));
        assert_eq!(decode_utf8_addr("a\\x{1F600}b").as_deref(), Some("a😀b"));
        for invalid in [
            "a\\x{}",
            "a\\x{1}",
            "a\\x{1234567}",
            "a\\y",
            "a b",
            "\\x{0A}",
            "\\x{D800}",
        ] {
            assert_eq!(decode_utf8_addr(invalid), None, "{invalid}");
        }
    }
}
