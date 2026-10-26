use lyxal_crypto::blake3_hex;

/// Moteur de calcul d'empreintes cryptographiques (BLAKE3) pour l'idempotence et la détection d'intégrité.
pub struct FingerprintEngine;

impl FingerprintEngine {
    /// Calcule le hash BLAKE3 du fichier brut source pour garantir l'idempotence de lot.
    pub fn compute_file_hash(content: &[u8]) -> String {
        blake3_hex(content)
    }

    /// Calcule l'empreinte canonique normalisée d'un article (`canonical_fingerprint`).
    ///
    /// Combine :
    /// - Fabricant normalisé
    /// - Référence fabricant normalisée
    /// - Code GTIN (si présent)
    /// - Libellé commercial normalisé
    /// - Unité de référence normalisée
    /// - Version des règles appliquées
    pub fn compute_canonical_fingerprint(
        fabricant: &str,
        reference_fabricant: &str,
        gtin: Option<&str>,
        libelle_commercial: &str,
        unite_reference: &str,
        rules_version: &str,
    ) -> String {
        let canonical_str = format!(
            "FAB:{fabricant}|REF:{reference}|GTIN:{gtin}|LIB:{libelle}|UNT:{unite}|VER:{rules}",
            fabricant = fabricant.trim().to_uppercase(),
            reference = reference_fabricant.trim().to_uppercase(),
            gtin = gtin.map(|g| g.trim()).unwrap_or("NONE"),
            libelle = libelle_commercial.trim(),
            unite = unite_reference.trim().to_uppercase(),
            rules = rules_version.trim()
        );
        blake3_hex(canonical_str.as_bytes())
    }

    /// Calcule le scellement cryptographique d'un manifeste de publication (`seal_hash`).
    ///
    /// Agrège l'ensemble trié des empreintes canoniques d'articles approuvés.
    /// Si un article a été modifié en base après l'approbation du manifeste, le recalcul du `seal_hash`
    /// divergera, provoquant le rejet immédiat de la publication.
    pub fn compute_manifest_seal(approved_fingerprints: &[String]) -> String {
        let mut sorted = approved_fingerprints.to_vec();
        sorted.sort();
        let payload = sorted.join("|");
        blake3_hex(payload.as_bytes())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_file_hash_stability() {
        let data = b"FABDIS;3.0;SAINT-GOBAIN;PLACO;BA13";
        let h1 = FingerprintEngine::compute_file_hash(data);
        let h2 = FingerprintEngine::compute_file_hash(data);
        assert_eq!(h1, h2);
        assert_eq!(h1.len(), 64);
    }

    #[test]
    fn test_canonical_fingerprint_normalization() {
        let f1 = FingerprintEngine::compute_canonical_fingerprint(
            "  saint-gobain placo ",
            " ba13_2500 ",
            Some(" 3456789012345 "),
            " Placoplatre BA13 ",
            " pce ",
            "1.0.0",
        );
        let f2 = FingerprintEngine::compute_canonical_fingerprint(
            "SAINT-GOBAIN PLACO",
            "BA13_2500",
            Some("3456789012345"),
            "Placoplatre BA13",
            "PCE",
            "1.0.0",
        );
        assert_eq!(f1, f2);
    }

    #[test]
    fn test_manifest_seal_tamper_detection() {
        let items = vec![
            "hash_item_1".to_string(),
            "hash_item_2".to_string(),
            "hash_item_3".to_string(),
        ];
        let seal1 = FingerprintEngine::compute_manifest_seal(&items);

        // Ordre inversé : le scellement reste identique car trié
        let items_reversed = vec![
            "hash_item_3".to_string(),
            "hash_item_1".to_string(),
            "hash_item_2".to_string(),
        ];
        let seal2 = FingerprintEngine::compute_manifest_seal(&items_reversed);
        assert_eq!(seal1, seal2);

        // Altération d'une empreinte : divergence garantie
        let items_tampered = vec![
            "hash_item_1".to_string(),
            "hash_item_2_MODIFIED".to_string(),
            "hash_item_3".to_string(),
        ];
        let seal3 = FingerprintEngine::compute_manifest_seal(&items_tampered);
        assert_ne!(seal1, seal3);
    }
}
