-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object.test.surql
-- Fonction     : fn::validation_object
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc. Dans Surrealist, sélectionner uniquement le test à exécuter lorsque
-- celui-ci attend une erreur.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Objet simple valide
-- Résultat attendu : { name: "Lyxal", enabled: true }
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal",
        enabled: true
    },
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 2 — Objet vide valide
-- Résultat attendu : {}
-- ============================================================================

RETURN fn::validation_object(
    {},
    "METADATA"
);


-- ============================================================================
-- TEST 3 — Objet imbriqué valide
-- Résultat attendu : objet contenant deux propriétés de premier niveau
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal",
        metadata: {
            source: "api",
            version: 1,
            enabled: true
        }
    },
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 4 — Objet contenant différentes valeurs
-- Résultat attendu : objet validé sans transformation
-- ============================================================================

RETURN fn::validation_object(
    {
        text: "Lyxal",
        number: 42,
        enabled: true,
        empty_value: NULL,
        items: [1, 2, 3],
        nested: {
            value: "test"
        }
    },
    "PAYLOAD"
);


-- ============================================================================
-- TEST 5 — Valeur absente
-- Erreur attendue : CONFIGURATION_REQUIRED
-- ============================================================================

RETURN fn::validation_object(
    NONE,
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 6 — Valeur NULL
-- Erreur attendue : CONFIGURATION_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_object(
    NULL,
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 7 — Chaîne JSON à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    '{"name":"Lyxal"}',
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 8 — Chaîne ordinaire à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    "Lyxal",
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 9 — Tableau à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    [
        {
            name: "Lyxal"
        }
    ],
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 10 — Entier à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    42,
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 11 — Booléen à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    true,
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 12 — Record ID à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    core_workspace:lyxal,
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 13 — Datetime à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    d"2026-08-02T10:00:00Z",
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 14 — Validation après décodage d'un JSON objet
-- Résultat attendu : { name: "Lyxal", enabled: true }
-- ============================================================================

LET $decoded_configuration = fn::validation_json(
    '{"name":"Lyxal","enabled":true}',
    "CONFIGURATION",
    10000
);

RETURN fn::validation_object(
    $decoded_configuration,
    "CONFIGURATION"
);


-- ============================================================================
-- TEST 15 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal"
    },
    "     "
);
