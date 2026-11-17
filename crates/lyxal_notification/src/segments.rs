//! Parties d'un SMS (décision E5) : alphabet GSM 03.38 (jeu de base : 1 unité ; extension
//! `^ { } \ [ ~ ] | €` : 2 unités) ; un seul caractère hors de cet alphabet fait passer tout le
//! texte en UCS-2 (unités UTF-16 : un caractère hors du plan de base, comme un emoji, en compte
//! 2). Un SMS seul porte 160 unités GSM-7 ou 70 UCS-2 ; au-delà, chaque partie en porte 153 ou 67.
//! Même calcul que `fn::notification_sms_segments` (contrôle du gabarit à l'enregistrement),
//! appliqué ici au texte rendu juste avant l'envoi.

/// Parties au plus d'un SMS.
pub const MAX_SMS_PARTS: u32 = 10;

const GSM_BASIC: &str = "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà";
const GSM_EXTENDED: &str = "^{}\\[~]|€";

/// Codage d'un SMS.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SmsEncoding {
    /// Alphabet GSM 7 bits.
    Gsm7,
    /// UCS-2 (UTF-16).
    Ucs2,
}

/// Comptage d'un texte de SMS.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct SmsSegments {
    /// Codage.
    pub encoding: SmsEncoding,
    /// Unités (septets GSM ou unités UTF-16).
    pub units: u32,
    /// Parties.
    pub parts: u32,
}

impl SmsSegments {
    /// Comptage de `text`.
    pub fn count(text: &str) -> Self {
        let gsm = text
            .chars()
            .all(|c| GSM_BASIC.contains(c) || GSM_EXTENDED.contains(c));
        let units: usize = if gsm {
            text.chars()
                .map(|c| if GSM_EXTENDED.contains(c) { 2 } else { 1 })
                .sum()
        } else {
            text.chars().map(char::len_utf16).sum()
        };
        let units = u32::try_from(units).unwrap_or(u32::MAX);
        let (single, part) = if gsm { (160, 153) } else { (70, 67) };
        let parts = if units <= single {
            1
        } else {
            units.div_ceil(part)
        };
        Self {
            encoding: if gsm {
                SmsEncoding::Gsm7
            } else {
                SmsEncoding::Ucs2
            },
            units,
            parts,
        }
    }

    /// Le texte tient dans 10 parties.
    pub fn fits(&self) -> bool {
        self.parts <= MAX_SMS_PARTS
    }

    /// Texte à envoyer en Unicode (UCS-2).
    pub fn unicode(&self) -> bool {
        self.encoding == SmsEncoding::Ucs2
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn gsm7_and_ucs2_parts_are_counted() {
        let count = SmsSegments::count;
        assert_eq!(
            count("Bonjour, votre devis est prete."),
            SmsSegments {
                encoding: SmsEncoding::Gsm7,
                units: 31,
                parts: 1
            }
        );
        assert_eq!(count(&"a".repeat(160)).parts, 1);
        assert_eq!(count(&"a".repeat(161)).parts, 2);
        assert_eq!(count(&"a".repeat(306)).parts, 2);
        assert_eq!(count(&"a".repeat(307)).parts, 3);
        // Extension : deux unités
        assert_eq!(count("{€}").units, 6);
        assert_eq!(count(&"€".repeat(80)).parts, 1);
        assert_eq!(count(&"€".repeat(81)).parts, 2);
        // Hors de l'alphabet GSM : UCS-2, emoji compté double
        assert_eq!(count("Devis prêt").encoding, SmsEncoding::Ucs2);
        assert_eq!(count("Merci 😀").units, 8);
        assert_eq!(count(&"ê".repeat(70)).parts, 1);
        assert_eq!(count(&"ê".repeat(71)).parts, 2);
        // 10 parties au plus
        assert!(count(&"a".repeat(1530)).fits());
        assert!(!count(&"a".repeat(1531)).fits());
        assert!(count(&"ê".repeat(670)).fits());
        assert!(!count(&"ê".repeat(671)).fits());
        assert!(count("Être là").unicode());
        assert!(!count("Etre la").unicode());
    }
}
