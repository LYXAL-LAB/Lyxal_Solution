-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/etag.test.surql
-- Fonction     : fn::validation_etag
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — ETag fort
-- Résultat attendu : "\"abc123\""
-- ============================================================================
RETURN fn::validation_etag(
    "\"abc123\"",
    "ETAG",
    true
);

-- ============================================================================
-- TEST 2 — ETag faible autorisé
-- Résultat attendu : "W/\"abc123\""
-- ============================================================================
RETURN fn::validation_etag(
    "W/\"abc123\"",
    "ETAG",
    true
);

-- ============================================================================
-- TEST 3 — ETag faible interdit
-- Erreur attendue : ETAG_WEAK_ETAG_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_etag(
    "W/\"abc123\"",
    "ETAG",
    false
);

-- ============================================================================
-- TEST 4 — Guillemets manquants
-- Erreur attendue : ETAG_INVALID_ETAG
-- ============================================================================
RETURN fn::validation_etag(
    "abc123",
    "ETAG",
    true
);
