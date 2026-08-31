-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/value_type.test.surql
-- Fonction     : fn::validation_value_type
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — String valide
-- Résultat attendu : "Lyxal"
-- ============================================================================
RETURN fn::validation_value_type("Lyxal", "VALUE", "string");

-- ============================================================================
-- TEST 2 — Int valide
-- Résultat attendu : 42
-- ============================================================================
RETURN fn::validation_value_type(42, "VALUE", "int");

-- ============================================================================
-- TEST 3 — Object valide
-- Résultat attendu : { enabled: true }
-- ============================================================================
RETURN fn::validation_value_type(
    { enabled: true },
    "VALUE",
    "object"
);

-- ============================================================================
-- TEST 4 — Type inattendu
-- Erreur attendue : VALUE_UNEXPECTED_TYPE
-- ============================================================================
RETURN fn::validation_value_type(42, "VALUE", "string");

-- ============================================================================
-- TEST 5 — Type attendu vide
-- Erreur attendue : VALIDATION_INVALID_EXPECTED_TYPE
-- ============================================================================
RETURN fn::validation_value_type(42, "VALUE", "   ");
