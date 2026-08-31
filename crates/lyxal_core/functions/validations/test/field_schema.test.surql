-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/field_schema.test.surql
-- Fonction     : fn::validation_field_schema
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Schéma valide
RETURN fn::validation_field_schema(
    {
        required: true,
        nullable: false,
        type: "string",
        min_length: 2,
        max_length: 100
    },
    "NAME_SCHEMA"
);

-- TEST 2 — Plage invalide
-- Erreur attendue : NAME_SCHEMA_INVALID_LENGTH_RANGE
RETURN fn::validation_field_schema(
    {
        type: "string",
        min_length: 100,
        max_length: 2
    },
    "NAME_SCHEMA"
);

-- TEST 3 — Clé inconnue
-- Erreur attendue : NAME_SCHEMA_UNKNOWN_SCHEMA_KEY
RETURN fn::validation_field_schema(
    {
        type: "string",
        transform: "trim"
    },
    "NAME_SCHEMA"
);
