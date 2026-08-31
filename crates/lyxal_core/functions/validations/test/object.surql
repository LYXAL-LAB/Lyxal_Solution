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
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Objet vide autorisé
-- Résultat attendu : {}
-- ============================================================================

RETURN fn::validation_object(
    {},
    "METADATA",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 3 — Objet contenant exactement une propriété
-- Résultat attendu : { name: "Lyxal" }
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal"
    },
    "CONFIGURATION",
    false,
    1,
    10
);


-- ============================================================================
-- TEST 4 — Objet contenant exactement la limite minimale
-- Résultat attendu : objet contenant deux propriétés
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal",
        enabled: true
    },
    "CONFIGURATION",
    false,
    2,
    10
);


-- ============================================================================
-- TEST 5 — Objet contenant exactement la limite maximale
-- Résultat attendu : objet contenant trois propriétés
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal",
        enabled: true,
        version: 1
    },
    "CONFIGURATION",
    false,
    1,
    3
);


-- ============================================================================
-- TEST 6 — Objet imbriqué valide
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
    "CONFIGURATION",
    false,
    2,
    2
);


-- ============================================================================
-- TEST 7 — Objet contenant différentes valeurs
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
    "PAYLOAD",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 8 — Valeur absente
-- Erreur attendue : CONFIGURATION_REQUIRED
-- ============================================================================

RETURN fn::validation_object(
    NONE,
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 9 — Valeur NULL
-- Erreur attendue : CONFIGURATION_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_object(
    NULL,
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 10 — Objet vide refusé
-- Erreur attendue : CONFIGURATION_EMPTY
-- ============================================================================

RETURN fn::validation_object(
    {},
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 11 — Objet vide autorisé mais minimum égal à un
-- Erreur attendue : CONFIGURATION_TOO_FEW_PROPERTIES
-- ============================================================================

RETURN fn::validation_object(
    {},
    "CONFIGURATION",
    true,
    1,
    NONE
);


-- ============================================================================
-- TEST 12 — Objet contenant trop peu de propriétés
-- Erreur attendue : CONFIGURATION_TOO_FEW_PROPERTIES
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal"
    },
    "CONFIGURATION",
    false,
    2,
    10
);


-- ============================================================================
-- TEST 13 — Objet contenant trop de propriétés
-- Erreur attendue : CONFIGURATION_TOO_MANY_PROPERTIES
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal",
        enabled: true,
        version: 1,
        source: "api"
    },
    "CONFIGURATION",
    false,
    1,
    3
);


-- ============================================================================
-- TEST 14 — Chaîne JSON à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    '{"name":"Lyxal"}',
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Chaîne ordinaire à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    "Lyxal",
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Tableau à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    [
        {
            name: "Lyxal"
        }
    ],
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Entier à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    42,
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Booléen à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    true,
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Record ID à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    core_workspace:lyxal,
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 20 — Datetime à la place d'un objet
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_object(
    d"2026-08-02T10:00:00Z",
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 21 — Minimum négatif
-- Erreur attendue : VALIDATION_INVALID_MIN_PROPERTIES
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal"
    },
    "CONFIGURATION",
    false,
    -1,
    10
);


-- ============================================================================
-- TEST 22 — Maximum négatif
-- Erreur attendue : VALIDATION_INVALID_MAX_PROPERTIES
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal"
    },
    "CONFIGURATION",
    false,
    0,
    -1
);


-- ============================================================================
-- TEST 23 — Plage de propriétés incohérente
-- Erreur attendue : VALIDATION_INVALID_OBJECT_RANGE
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal"
    },
    "CONFIGURATION",
    false,
    10,
    2
);


-- ============================================================================
-- TEST 24 — Limite minimale égale à zéro
-- Résultat attendu : {}
-- ============================================================================

RETURN fn::validation_object(
    {},
    "METADATA",
    true,
    0,
    NONE
);


-- ============================================================================
-- TEST 25 — Limite maximale égale à zéro avec objet vide
-- Résultat attendu : {}
-- ============================================================================

RETURN fn::validation_object(
    {},
    "METADATA",
    true,
    NONE,
    0
);


-- ============================================================================
-- TEST 26 — Limite maximale égale à zéro avec objet non vide
-- Erreur attendue : METADATA_TOO_MANY_PROPERTIES
-- ============================================================================

RETURN fn::validation_object(
    {
        source: "api"
    },
    "METADATA",
    true,
    NONE,
    0
);


-- ============================================================================
-- TEST 27 — Validation après décodage d'un JSON objet
-- Résultat attendu : { name: "Lyxal", enabled: true }
-- ============================================================================

LET $decoded_configuration = fn::validation_json(
    '{"name":"Lyxal","enabled":true}',
    "CONFIGURATION",
    10000
);

RETURN fn::validation_object(
    $decoded_configuration,
    "CONFIGURATION",
    false,
    1,
    20
);


-- ============================================================================
-- TEST 28 — Validation après décodage d'un JSON tableau
-- Erreur attendue : CONFIGURATION_INVALID_TYPE
-- ============================================================================

LET $decoded_configuration = fn::validation_json(
    '["booking","calendar"]',
    "CONFIGURATION",
    10000
);

RETURN fn::validation_object(
    $decoded_configuration,
    "CONFIGURATION",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 29 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_object(
    {
        name: "Lyxal"
    },
    "     ",
    false,
    NONE,
    NONE
);