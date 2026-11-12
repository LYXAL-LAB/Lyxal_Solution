//! Type réel d'un fichier, reconnu à partir de ses premiers octets (`infer`).

/// Nombre d'octets du début du fichier gardés pour reconnaître son type.
pub const HEAD_SIZE: usize = 8192;

/// Type enregistré quand rien ne permet d'en retenir un autre.
pub const DEFAULT_CONTENT_TYPE: &str = "application/octet-stream";

/// Type à enregistrer pour un fichier dont on connaît le début et le type annoncé :
///
/// 1. le type reconnu dans le contenu, s'il y en a un ;
/// 2. sinon le type annoncé, s'il n'est pas de ceux que le contenu permet de reconnaître
///    (texte, CSV, JSON…) ;
/// 3. sinon `application/octet-stream` : un type annoncé que le contenu dément n'est pas cru.
pub fn detect(head: &[u8], declared: Option<&str>) -> String {
    if let Some(found) = infer::get(head) {
        return found.mime_type().to_string();
    }
    match declared {
        Some(declared) if !infer::is_mime_supported(declared) => declared.to_string(),
        _ => DEFAULT_CONTENT_TYPE.to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const PNG: &[u8] = b"\x89PNG\r\n\x1a\n\0\0\0\rIHDR";

    /// Début d'un programme Linux (ELF exécutable).
    fn elf() -> Vec<u8> {
        let mut program = vec![0u8; 64];
        program[..7].copy_from_slice(b"\x7fELF\x02\x01\x01");
        program[16] = 2;
        program
    }

    #[test]
    fn the_content_decides_over_the_announcement() {
        assert_eq!(detect(PNG, Some("image/png")), "image/png");
        assert_eq!(detect(PNG, Some("text/plain")), "image/png");
        assert_eq!(detect(PNG, None), "image/png");
        assert_eq!(detect(b"%PDF-1.7\n", Some("image/png")), "application/pdf");
        // Programme Linux annoncé comme une image
        assert_eq!(
            detect(&elf(), Some("image/png")),
            "application/x-executable"
        );
    }

    #[test]
    fn an_unrecognised_content_keeps_a_plausible_announcement_only() {
        let text = b"nom;prix\nvis;0,12\n";
        assert_eq!(detect(text, Some("text/csv")), "text/csv");
        assert_eq!(detect(text, Some("application/json")), "application/json");
        // Type que le contenu aurait dû confirmer : pas cru
        assert_eq!(detect(text, Some("image/png")), DEFAULT_CONTENT_TYPE);
        assert_eq!(detect(text, Some("application/pdf")), DEFAULT_CONTENT_TYPE);
        assert_eq!(detect(text, None), DEFAULT_CONTENT_TYPE);
        assert_eq!(detect(b"", Some("text/plain")), "text/plain");
    }
}
