//! Contrôle et normalisation des identifiants GS1 (GTIN-8, GTIN-12, GTIN-13, GTIN-14).
//!
//! Important : Conformément à la directive CTO, la conformité d'un GTIN ne suffit
//! jamais à attribuer le statut VERIFIED à un article.

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GtinValidationError {
    Empty,
    InvalidCharacters,
    InvalidLength(usize),
    ChecksumMismatch { expected: u8, calculated: u8 },
}

impl std::fmt::Display for GtinValidationError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Empty => write!(f, "Le code GTIN est vide"),
            Self::InvalidCharacters => write!(f, "Le code GTIN contient des caractères non numériques"),
            Self::InvalidLength(len) => write!(f, "Longueur de GTIN non reconnue ({len} chiffres, attendu 8, 12, 13 ou 14)"),
            Self::ChecksumMismatch { expected, calculated } => {
                write!(f, "Clé de contrôle GS1 Modulo 10 erronée (attendu {expected}, calculé {calculated})")
            }
        }
    }
}

/// Normalise et valide un code GTIN/EAN selon l'algorithme officiel GS1 Modulo 10.
pub fn validate_and_normalize_gtin(raw_gtin: &str) -> Result<String, GtinValidationError> {
    let cleaned: String = raw_gtin
        .chars()
        .filter(|c| !c.is_whitespace() && *c != '-' && *c != '.')
        .collect();

    if cleaned.is_empty() {
        return Err(GtinValidationError::Empty);
    }

    if !cleaned.chars().all(|c| c.is_ascii_digit()) {
        return Err(GtinValidationError::InvalidCharacters);
    }

    let len = cleaned.len();
    if len != 8 && len != 12 && len != 13 && len != 14 {
        return Err(GtinValidationError::InvalidLength(len));
    }

    let digits: Vec<u8> = cleaned
        .chars()
        .map(|c| c.to_digit(10).unwrap() as u8)
        .collect();

    let check_digit = *digits.last().unwrap();
    let body = &digits[..len - 1];

    // Algorithme officiel GS1 : les coefficients (3 et 1) s'appliquent en partant de droite (avant le check digit)
    let mut sum = 0;
    let mut multiplier = 3;
    for &d in body.iter().rev() {
        sum += (d as u32) * multiplier;
        multiplier = if multiplier == 3 { 1 } else { 3 };
    }

    let calculated_check = match sum % 10 {
        0 => 0,
        rem => (10 - rem) as u8,
    };

    if check_digit != calculated_check {
        return Err(GtinValidationError::ChecksumMismatch {
            expected: check_digit,
            calculated: calculated_check,
        });
    }

    // Normalisation en format standard 13 chiffres (zéro-padding si GTIN-12) ou 14 chiffres si GTIN-14
    if len == 12 {
        Ok(format!("0{cleaned}"))
    } else {
        Ok(cleaned)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_gtin13() {
        // EAN officiel valide : 3 017620 422003
        let valid_ean = "3017620422003";
        assert_eq!(validate_and_normalize_gtin(valid_ean), Ok("3017620422003".to_string()));
    }

    #[test]
    fn test_invalid_checksum() {
        let invalid_ean = "3017620422009"; // mauvais check digit
        assert!(matches!(
            validate_and_normalize_gtin(invalid_ean),
            Err(GtinValidationError::ChecksumMismatch { .. })
        ));
    }

    #[test]
    fn test_invalid_length() {
        assert!(matches!(
            validate_and_normalize_gtin("12345"),
            Err(GtinValidationError::InvalidLength(5))
        ));
    }
}
