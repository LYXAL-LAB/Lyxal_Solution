-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/checksum.test.surql
-- Fonction     : fn::validation_checksum
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — CRC32 valide
-- Résultat attendu : "cbf43926"
-- ============================================================================
RETURN fn::validation_checksum(
    "CBF43926",
    "CHECKSUM",
    "crc32"
);

-- ============================================================================
-- TEST 2 — SHA-256 valide
-- Résultat attendu : valeur en minuscules
-- ============================================================================
RETURN fn::validation_checksum(
    "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
    "CHECKSUM",
    "sha256"
);

-- ============================================================================
-- TEST 3 — Longueur incorrecte
-- Erreur attendue : CHECKSUM_INVALID_CHECKSUM_LENGTH
-- ============================================================================
RETURN fn::validation_checksum(
    "AABBCC",
    "CHECKSUM",
    "sha256"
);

-- ============================================================================
-- TEST 4 — Algorithme inconnu
-- Erreur attendue : VALIDATION_UNSUPPORTED_CHECKSUM_ALGORITHM
-- ============================================================================
RETURN fn::validation_checksum(
    "AABBCC",
    "CHECKSUM",
    "blake3"
);
