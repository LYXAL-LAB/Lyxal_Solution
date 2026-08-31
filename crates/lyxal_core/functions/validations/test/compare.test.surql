-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/compare.test.surql
-- Fonction     : fn::validation_compare
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Supérieur ou égal
-- Résultat attendu : objet de comparaison
-- ============================================================================
RETURN fn::validation_compare(
    18,
    18,
    "AGE",
    "gte"
);

-- ============================================================================
-- TEST 2 — Date de fin après date de début
-- Résultat attendu : objet de comparaison
-- ============================================================================
RETURN fn::validation_compare(
    d"2026-08-10T00:00:00Z",
    d"2026-08-01T00:00:00Z",
    "DATE_RANGE",
    "gt"
);

-- ============================================================================
-- TEST 3 — Comparaison échouée
-- Erreur attendue : AGE_COMPARISON_FAILED
-- ============================================================================
RETURN fn::validation_compare(
    17,
    18,
    "AGE",
    "gte"
);
