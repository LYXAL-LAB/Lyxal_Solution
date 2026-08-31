-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/apply_type.test.surql
-- Fonction     : fn::validation_apply_type
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Type string valide
RETURN fn::validation_apply_type(
    "Lyxal",
    "NAME",
    "string"
);

-- TEST 2 — Type incorrect
-- Erreur attendue : AGE_INVALID_TYPE
RETURN fn::validation_apply_type(
    "18",
    "AGE",
    "int"
);

-- TEST 3 — Valeur absente
RETURN fn::validation_apply_type(
    NONE,
    "AGE",
    "int"
);
