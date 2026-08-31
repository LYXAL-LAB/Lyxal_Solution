-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/float.test.surql
-- Fonction     : fn::validation_float
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc.
--
-- Dans Surrealist, sélectionner uniquement le test concerné lorsqu'une erreur
-- est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Valeur float valide sans limites
-- Résultat attendu : 19.99f
-- ============================================================================

RETURN fn::validation_float(
    19.99f,
    "MEASUREMENT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Valeur float entière
-- Résultat attendu : 100f
-- ============================================================================

RETURN fn::validation_float(
    100f,
    "MEASUREMENT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 3 — Valeur float égale à zéro
-- Résultat attendu : 0f
-- ============================================================================

RETURN fn::validation_float(
    0f,
    "MEASUREMENT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 4 — Valeur float négative
-- Résultat attendu : -125.5f
-- ============================================================================

RETURN fn::validation_float(
    -125.5f,
    "TEMPERATURE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 5 — Valeur comprise dans une plage
-- Résultat attendu : 50.25f
-- ============================================================================

RETURN fn::validation_float(
    50.25f,
    "SCORE",
    0f,
    100f
);


-- ============================================================================
-- TEST 6 — Valeur égale à la limite minimale
-- Résultat attendu : 0f
-- ============================================================================

RETURN fn::validation_float(
    0f,
    "SCORE",
    0f,
    100f
);


-- ============================================================================
-- TEST 7 — Valeur égale à la limite maximale
-- Résultat attendu : 100f
-- ============================================================================

RETURN fn::validation_float(
    100f,
    "SCORE",
    0f,
    100f
);


-- ============================================================================
-- TEST 8 — Limite minimale uniquement
-- Résultat attendu : 1500.75f
-- ============================================================================

RETURN fn::validation_float(
    1500.75f,
    "DISTANCE",
    0f,
    NONE
);


-- ============================================================================
-- TEST 9 — Limite maximale uniquement
-- Résultat attendu : -10.5f
-- ============================================================================

RETURN fn::validation_float(
    -10.5f,
    "TEMPERATURE",
    NONE,
    100f
);


-- ============================================================================
-- TEST 10 — Valeur absente
-- Erreur attendue : TEMPERATURE_REQUIRED
-- ============================================================================

RETURN fn::validation_float(
    NONE,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 11 — Valeur NULL
-- Erreur attendue : TEMPERATURE_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_float(
    NULL,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 12 — Entier à la place d'un float
-- Erreur attendue : TEMPERATURE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_float(
    19,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 13 — Entier zéro à la place d'un float
-- Erreur attendue : TEMPERATURE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_float(
    0,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 14 — Decimal à la place d'un float
-- Erreur attendue : TEMPERATURE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_float(
    19.99dec,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 15 — Chaîne contenant un float
-- Erreur attendue : TEMPERATURE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_float(
    "19.99",
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 16 — Booléen à la place d'un float
-- Erreur attendue : TEMPERATURE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_float(
    true,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 17 — Tableau à la place d'un float
-- Erreur attendue : TEMPERATURE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_float(
    [19.99f],
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 18 — Objet à la place d'un float
-- Erreur attendue : TEMPERATURE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_float(
    {
        value: 19.99f
    },
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 19 — Valeur inférieure à la limite minimale
-- Erreur attendue : TEMPERATURE_TOO_SMALL
-- ============================================================================

RETURN fn::validation_float(
    -100.01f,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 20 — Valeur supérieure à la limite maximale
-- Erreur attendue : TEMPERATURE_TOO_LARGE
-- ============================================================================

RETURN fn::validation_float(
    100.01f,
    "TEMPERATURE",
    -100f,
    100f
);


-- ============================================================================
-- TEST 21 — Plage incohérente
-- Erreur attendue : VALIDATION_INVALID_FLOAT_RANGE
-- ============================================================================

RETURN fn::validation_float(
    50f,
    "SCORE",
    100f,
    10f
);


-- ============================================================================
-- TEST 22 — Minimum et maximum identiques avec valeur identique
-- Résultat attendu : 50f
-- ============================================================================

RETURN fn::validation_float(
    50f,
    "VALUE",
    50f,
    50f
);


-- ============================================================================
-- TEST 23 — Minimum et maximum identiques avec valeur inférieure
-- Erreur attendue : VALUE_TOO_SMALL
-- ============================================================================

RETURN fn::validation_float(
    49.99f,
    "VALUE",
    50f,
    50f
);


-- ============================================================================
-- TEST 24 — Minimum et maximum identiques avec valeur supérieure
-- Erreur attendue : VALUE_TOO_LARGE
-- ============================================================================

RETURN fn::validation_float(
    50.01f,
    "VALUE",
    50f,
    50f
);


-- ============================================================================
-- TEST 25 — Conversion explicite d'une chaîne avant validation
-- Résultat attendu : 19.99f
-- ============================================================================

LET $converted_value = type::float(
    "19.99"
);

RETURN fn::validation_float(
    $converted_value,
    "MEASUREMENT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 26 — Conversion explicite d'un entier avant validation
-- Résultat attendu : 19f
-- ============================================================================

LET $converted_value = type::float(
    19
);

RETURN fn::validation_float(
    $converted_value,
    "MEASUREMENT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 27 — Conversion explicite d'un decimal avant validation
-- Résultat attendu : valeur float issue de 19.99dec
-- ============================================================================

LET $converted_value = type::float(
    19.99dec
);

RETURN fn::validation_float(
    $converted_value,
    "MEASUREMENT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 28 — Petite valeur positive
-- Résultat attendu : 0.000001f
-- ============================================================================

RETURN fn::validation_float(
    0.000001f,
    "RATIO",
    0f,
    1f
);


-- ============================================================================
-- TEST 29 — Valeur négative autorisée
-- Résultat attendu : -9999.99f
-- ============================================================================

RETURN fn::validation_float(
    -9999.99f,
    "MEASUREMENT",
    -10000f,
    10000f
);


-- ============================================================================
-- TEST 30 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_float(
    19.99f,
    "     ",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 31 — Différence avec validation_number
-- Résultat attendu : 19
-- Note : validation_number accepte un int contrairement à validation_float
-- ============================================================================

RETURN fn::validation_number(
    19,
    "MEASUREMENT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 32 — Enchaînement après conversion explicite
-- Résultat attendu : 25.5f
-- ============================================================================

LET $measurement = type::float(
    "25.5"
);

RETURN fn::validation_float(
    $measurement,
    "MEASUREMENT",
    0f,
    100f
);