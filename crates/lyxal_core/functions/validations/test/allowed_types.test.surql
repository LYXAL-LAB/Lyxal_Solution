-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/allowed_types.test.surql
-- Fonction     : fn::validation_allowed_types
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Entier autorisé
-- Résultat attendu : 42
-- ============================================================================
RETURN fn::validation_allowed_types(
    42,
    "VALUE",
    ["int", "decimal"]
);

-- ============================================================================
-- TEST 2 — Decimal autorisé
-- Résultat attendu : 42dec
-- ============================================================================
RETURN fn::validation_allowed_types(
    42dec,
    "VALUE",
    ["int", "decimal"]
);

-- ============================================================================
-- TEST 3 — String interdite
-- Erreur attendue : VALUE_TYPE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_allowed_types(
    "42",
    "VALUE",
    ["int", "decimal"]
);

-- ============================================================================
-- TEST 4 — Liste vide
-- Erreur attendue : VALIDATION_EMPTY_ALLOWED_TYPES
-- ============================================================================
RETURN fn::validation_allowed_types(42, "VALUE", []);

-- ============================================================================
-- TEST 5 — Nom de type vide
-- Erreur attendue : VALIDATION_INVALID_ALLOWED_TYPE
-- ============================================================================
RETURN fn::validation_allowed_types(42, "VALUE", ["int", "   "]);
