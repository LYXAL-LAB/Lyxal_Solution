// SPDX-License-Identifier: AGPL-3.0-only

//! Codages des parties d'un avis : quoted-printable (RFC 2045 §6.7) pour le texte lisible,
//! Base64 et quoted-printable à la lecture, assainissement et repli des champs.

use base64::alphabet;
use base64::engine::{DecodePaddingMode, GeneralPurpose, GeneralPurposeConfig};
use base64::Engine as _;

use super::{MAX_DSN_LINE_BYTES, MAX_FIELD_BYTES};

/// Longueur d'une ligne quoted-printable, signe `=` de coupure compris (RFC 2045 §6.7 règle 5).
const QP_LINE: usize = 76;
/// Longueur visée d'une ligne de champ repliée (RFC 5322 §2.1.1 : 78 recommandés).
const FOLD_TARGET: usize = 78;

const BASE64_LENIENT: GeneralPurpose = GeneralPurpose::new(
    &alphabet::STANDARD,
    GeneralPurposeConfig::new()
        .with_decode_padding_mode(DecodePaddingMode::Indifferent)
        .with_decode_allow_trailing_bits(true),
);

/// Code un texte en quoted-printable ; `\n` devient une fin de ligne CRLF.
pub(super) fn encode_quoted_printable(text: &str, out: &mut Vec<u8>) {
    for (index, line) in text.split('\n').enumerate() {
        if index > 0 {
            out.extend_from_slice(b"\r\n");
        }
        let bytes = line.as_bytes();
        let mut width = 0;
        for (position, &byte) in bytes.iter().enumerate() {
            let last = position + 1 == bytes.len();
            let literal = match byte {
                b'=' => false,
                b' ' | b'\t' => !last,
                b'!'..=b'~' => true,
                _ => false,
            };
            let needed = if literal { 1 } else { 3 };
            // Place gardée pour le `=` de coupure, sauf pour le dernier octet de la ligne.
            let reserve = usize::from(!last);
            if width + needed + reserve > QP_LINE {
                out.extend_from_slice(b"=\r\n");
                width = 0;
            }
            if literal {
                out.push(byte);
            } else {
                out.extend_from_slice(format!("={byte:02X}").as_bytes());
            }
            width += needed;
        }
    }
}

/// Décode du quoted-printable, tolérant (une séquence `=` invalide est gardée telle quelle).
pub(super) fn decode_quoted_printable(input: &[u8]) -> Vec<u8> {
    let mut out = Vec::with_capacity(input.len());
    let mut index = 0;
    while index < input.len() {
        let byte = input[index];
        if byte != b'=' {
            out.push(byte);
            index += 1;
            continue;
        }
        let rest = &input[index + 1..];
        if rest.starts_with(b"\r\n") {
            index += 3;
        } else if rest.starts_with(b"\n") {
            index += 2;
        } else if let (Some(high), Some(low)) = (
            rest.first().and_then(|&b| hex_value(b)),
            rest.get(1).and_then(|&b| hex_value(b)),
        ) {
            out.push(high << 4 | low);
            index += 3;
        } else {
            out.push(b'=');
            index += 1;
        }
    }
    out
}

/// Décode du Base64 en ignorant les blancs et les fins de ligne ; `None` s'il est invalide.
pub(super) fn decode_base64(input: &[u8]) -> Option<Vec<u8>> {
    let compact: Vec<u8> = input
        .iter()
        .copied()
        .filter(|byte| !byte.is_ascii_whitespace())
        .collect();
    BASE64_LENIENT.decode(compact).ok()
}

/// Assainit la valeur d'un champ : caractères de commande retirés (tabulation remplacée par une
/// espace), non ASCII remplacé par `?` hors d'un avis international, espaces de tête et de fin
/// retirées, [`MAX_FIELD_BYTES`] octets au plus.
pub(super) fn sanitize_field(value: &str, international: bool) -> String {
    let mut out = String::with_capacity(value.len().min(MAX_FIELD_BYTES));
    for ch in value.chars() {
        let ch = match ch {
            '\t' => ' ',
            ch if ch.is_control() => continue,
            ch if !ch.is_ascii() && !international => '?',
            ch => ch,
        };
        if out.len() + ch.len_utf8() > MAX_FIELD_BYTES {
            break;
        }
        out.push(ch);
    }
    out.trim().to_owned()
}

/// Écrit `Nom: valeur` replié aux espaces (lignes de 78 octets visés, [`MAX_DSN_LINE_BYTES`]
/// au plus), CRLF final compris. La valeur est déjà assainie : le repli insère un CRLF devant
/// une espace existante, de sorte que le dépliage (RFC 5322 §2.2.3) redonne la valeur ; un mot
/// plus long qu'une ligne est coupé (une espace est alors ajoutée à la relecture).
pub(super) fn write_field(out: &mut Vec<u8>, name: &str, value: &str) {
    out.extend_from_slice(name.as_bytes());
    out.extend_from_slice(b":");
    let mut width = name.len() + 1;
    // Chaque mot est précédé de l'espace qui le sépare du précédent.
    for word in value.split(' ') {
        let mut word = word;
        if width + 1 + word.len() > FOLD_TARGET && width > name.len() + 1 {
            out.extend_from_slice(b"\r\n");
            width = 0;
        }
        out.push(b' ');
        width += 1;
        while width + word.len() > MAX_DSN_LINE_BYTES {
            let mut cut = MAX_DSN_LINE_BYTES - width;
            while cut > 0 && !word.is_char_boundary(cut) {
                cut -= 1;
            }
            out.extend_from_slice(&word.as_bytes()[..cut]);
            out.extend_from_slice(b"\r\n ");
            word = &word[cut..];
            width = 1;
        }
        out.extend_from_slice(word.as_bytes());
        width += word.len();
    }
    out.extend_from_slice(b"\r\n");
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
#[allow(clippy::unwrap_used, clippy::expect_used, clippy::panic)]
mod tests {
    use super::*;

    #[test]
    fn quoted_printable_round_trip() {
        let text = format!("Été = \"ok\" \nfin \n{}é\n\n", "x".repeat(200));
        let mut out = Vec::new();
        encode_quoted_printable(&text, &mut out);
        assert!(out.is_ascii());
        for line in out.split(|&b| b == b'\n') {
            let line = line.strip_suffix(b"\r").unwrap_or(line);
            assert!(line.len() <= QP_LINE, "{}", String::from_utf8_lossy(line));
            assert!(!line.ends_with(b" "));
        }
        let decoded = decode_quoted_printable(&out);
        assert_eq!(
            String::from_utf8(decoded).expect("UTF-8"),
            text.replace('\n', "\r\n")
        );
        assert_eq!(decode_quoted_printable(b"a=ZZb=4"), b"a=ZZb=4");
    }

    #[test]
    fn fields_fold_and_unfold() {
        let value = sanitize_field(
            &format!("smtp; 550 5.1.1 {}\r\n\0fin", "mot ".repeat(400)),
            false,
        );
        assert!(value.len() <= MAX_FIELD_BYTES);
        let mut out = Vec::new();
        write_field(&mut out, "Diagnostic-Code", &value);
        let text = String::from_utf8(out).expect("UTF-8");
        assert!(text.ends_with("\r\n"));
        for line in text.split("\r\n") {
            assert!(line.len() <= FOLD_TARGET, "{line}");
        }
        let unfolded = text.trim_end_matches("\r\n").replace("\r\n", "");
        assert_eq!(unfolded, format!("Diagnostic-Code: {value}"));

        let long = "y".repeat(3000);
        let mut out = Vec::new();
        write_field(&mut out, "Remote-MTA", &long);
        for line in out.split(|&b| b == b'\n') {
            assert!(line.len() <= MAX_DSN_LINE_BYTES + 1);
        }
        assert_eq!(sanitize_field("  é\tx ", false), "? x");
        assert_eq!(sanitize_field("é", true), "é");
    }
}
