-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/object_schema_v2.test.surql
-- Fonction     : fn::validation_object_schema_v2
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Schéma d'objet valide
RETURN fn::validation_object_schema_v2(
    {
        name: {
            required: true,
            type: "string",
            min_length: 2
        },
        age: {
            type: "int",
            min: 18
        }
    },
    "USER_SCHEMA"
);

-- TEST 2 — Nom de champ invalide
-- Erreur attendue : USER_SCHEMA_INVALID_SCHEMA_FIELD_NAME
RETURN fn::validation_object_schema_v2(
    {
        "profile.name": {
            type: "string"
        }
    },
    "USER_SCHEMA"
);
