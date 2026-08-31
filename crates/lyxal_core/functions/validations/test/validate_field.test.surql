-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/validate_field.test.surql
-- Fonction     : fn::validation_validate_field
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Champ valide
RETURN fn::validation_validate_field(
    "Lyxal",
    "NAME",
    {
        required: true,
        type: "string",
        min_length: 2,
        max_length: 100
    }
);

-- TEST 2 — Champ absent
-- Erreur attendue : NAME_REQUIRED
RETURN fn::validation_validate_field(
    NONE,
    "NAME",
    {
        required: true,
        type: "string"
    }
);

-- TEST 3 — Type incorrect
-- Erreur attendue : AGE_INVALID_TYPE
RETURN fn::validation_validate_field(
    "18",
    "AGE",
    {
        type: "int",
        min: 18,
        max: 120
    }
);
