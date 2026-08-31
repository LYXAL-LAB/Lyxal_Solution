-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/totp_secret.test.surql
-- Fonction     : fn::validation_totp_secret
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Secret valide
-- Résultat attendu : "JBSWY3DPEHPK3PXP"
-- ============================================================================
RETURN fn::validation_totp_secret(
    "jbswy3dpehpk3pxp",
    "TOTP_SECRET",
    16,
    128
);

-- ============================================================================
-- TEST 2 — Caractère 0 interdit en Base32
-- Erreur attendue : TOTP_SECRET_INVALID_TOTP_SECRET
-- ============================================================================
RETURN fn::validation_totp_secret(
    "JBSWY3DP0HPK3PXP",
    "TOTP_SECRET",
    16,
    128
);

-- ============================================================================
-- TEST 3 — Padding interdit
-- Erreur attendue : TOTP_SECRET_INVALID_TOTP_SECRET
-- ============================================================================
RETURN fn::validation_totp_secret(
    "JBSWY3DPEHPK3PXP=",
    "TOTP_SECRET",
    16,
    128
);
