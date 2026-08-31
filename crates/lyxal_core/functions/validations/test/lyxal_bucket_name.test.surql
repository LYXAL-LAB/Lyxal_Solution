-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_bucket_name.test.surql
-- Fonction     : fn::validation_lyxal_bucket_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Bucket valide
-- Résultat attendu : "lyxal-assets"
-- ============================================================================
RETURN fn::validation_lyxal_bucket_name(
    "Lyxal-Assets",
    "BUCKET_NAME",
    3,
    63
);

-- ============================================================================
-- TEST 2 — Bucket client
-- Résultat attendu : "client42-documents"
-- ============================================================================
RETURN fn::validation_lyxal_bucket_name(
    "client42-documents",
    "BUCKET_NAME",
    3,
    63
);

-- ============================================================================
-- TEST 3 — Tiret bas interdit
-- Erreur attendue : BUCKET_NAME_INVALID_BUCKET_NAME
-- ============================================================================
RETURN fn::validation_lyxal_bucket_name(
    "lyxal_assets",
    "BUCKET_NAME",
    3,
    63
);

-- ============================================================================
-- TEST 4 — Forme IPv4 interdite
-- Erreur attendue : BUCKET_NAME_IP_LIKE_BUCKET_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_lyxal_bucket_name(
    "192.168.1.1",
    "BUCKET_NAME",
    3,
    63
);
