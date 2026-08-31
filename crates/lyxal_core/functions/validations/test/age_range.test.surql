-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/age_range.test.surql
-- Fonction     : fn::validation_age_range
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Adulte
-- Résultat attendu : objet avec âge calculé
-- ============================================================================
RETURN fn::validation_age_range(
    d"1980-05-10T00:00:00Z",
    "AGE",
    18,
    120
);

-- ============================================================================
-- TEST 2 — Date future
-- Erreur attendue : AGE_INVALID_BIRTHDATE
-- ============================================================================
RETURN fn::validation_age_range(
    d"2100-01-01T00:00:00Z",
    "AGE",
    18,
    120
);
