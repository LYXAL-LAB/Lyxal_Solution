-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/origin.test.surql
-- Fonction     : fn::validation_origin
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Origine HTTPS
-- Résultat attendu : "https://lyxal.com"
-- ============================================================================
RETURN fn::validation_origin(
    "HTTPS://LYXAL.COM", "ORIGIN", false, true, false
);

-- ============================================================================
-- TEST 2 — Origine locale avec port
-- Résultat attendu : "http://localhost:3000"
-- ============================================================================
RETURN fn::validation_origin(
    "http://localhost:3000", "ORIGIN", true, false, true
);

-- ============================================================================
-- TEST 3 — Chemin interdit
-- Erreur attendue : ORIGIN_INVALID_ORIGIN
-- ============================================================================
RETURN fn::validation_origin(
    "https://lyxal.com/api", "ORIGIN", false, true, false
);

-- ============================================================================
-- TEST 4 — Port interdit
-- Erreur attendue : ORIGIN_ORIGIN_PORT_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_origin(
    "https://lyxal.com:8443", "ORIGIN", false, true, false
);

-- ============================================================================
-- TEST 5 — HTTP interdit
-- Erreur attendue : ORIGIN_ORIGIN_SCHEME_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_origin(
    "http://lyxal.com", "ORIGIN", false, true, false
);
