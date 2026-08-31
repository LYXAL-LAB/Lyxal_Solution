-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/validate_object.test.surql
-- Fonction     : fn::validation_validate_object
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Objet valide
RETURN fn::validation_validate_object(
    {
        name: "Lyxal",
        age: 18,
        role: "admin"
    },
    "USER",
    {
        name: {
            required: true,
            type: "string",
            min_length: 2
        },
        age: {
            required: true,
            type: "int",
            min: 18,
            max: 120
        },
        role: {
            type: "string",
            enum: ["admin", "member"]
        }
    },
    false
);

-- TEST 2 — Clé inconnue
-- Erreur attendue : USER_UNKNOWN_KEY
RETURN fn::validation_validate_object(
    {
        name: "Lyxal",
        unexpected: true
    },
    "USER",
    {
        name: {
            required: true,
            type: "string"
        }
    },
    false
);

-- TEST 3 — Champ requis absent
-- Erreur attendue : NAME_REQUIRED
RETURN fn::validation_validate_object(
    {
        age: 18
    },
    "USER",
    {
        name: {
            required: true,
            type: "string"
        },
        age: {
            type: "int"
        }
    },
    false
);
