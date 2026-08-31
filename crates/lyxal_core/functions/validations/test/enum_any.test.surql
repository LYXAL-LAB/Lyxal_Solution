-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/enum_any.test.surql
-- Fonction     : fn::validation_enum_any
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
-- Résultat attendu : 2
-- ============================================================================
RETURN fn::validation_enum_any(2, "LEVEL", [1, 2, 3]);

-- ============================================================================
-- TEST 2 — Booléen autorisé
-- Résultat attendu : true
-- ============================================================================
RETURN fn::validation_enum_any(
    true,
    "ENABLED",
    [true, false]
);

-- ============================================================================
-- TEST 3 — Record ID autorisé
-- Résultat attendu : role:admin
-- ============================================================================
RETURN fn::validation_enum_any(
    role:admin,
    "ROLE_ID",
    [role:admin, role:member]
);

-- ============================================================================
-- TEST 4 — Type différent non égal
-- Erreur attendue : LEVEL_VALUE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_enum_any("2", "LEVEL", [1, 2, 3]);

-- ============================================================================
-- TEST 5 — Liste vide
-- Erreur attendue : VALIDATION_EMPTY_ENUM_VALUES
-- ============================================================================
RETURN fn::validation_enum_any(1, "LEVEL", []);
