-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/decimal.test.surql
-- Fonction     : fn::validation_decimal
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
-- TEST 1 — Valeur decimal valide sans limites
-- Résultat attendu : 19.99dec
-- ============================================================================

RETURN fn::validation_decimal(
    19.99dec,
    "PRICE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Valeur decimal entière
-- Résultat attendu : 100dec
-- ============================================================================

RETURN fn::validation_decimal(
    100dec,
    "AMOUNT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 3 — Valeur decimal égale à zéro
-- Résultat attendu : 0dec
-- ============================================================================

RETURN fn::validation_decimal(
    0dec,
    "AMOUNT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 4 — Valeur decimal négative
-- Résultat attendu : -125.50dec
-- ============================================================================

RETURN fn::validation_decimal(
    -125.50dec,
    "BALANCE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 5 — Valeur comprise dans une plage
-- Résultat attendu : 50.25dec
-- ============================================================================

RETURN fn::validation_decimal(
    50.25dec,
    "PERCENTAGE",
    0dec,
    100dec
);


-- ============================================================================
-- TEST 6 — Valeur égale à la limite minimale
-- Résultat attendu : 0dec
-- ============================================================================

RETURN fn::validation_decimal(
    0dec,
    "PRICE",
    0dec,
    1000dec
);


-- ============================================================================
-- TEST 7 — Valeur égale à la limite maximale
-- Résultat attendu : 1000dec
-- ============================================================================

RETURN fn::validation_decimal(
    1000dec,
    "PRICE",
    0dec,
    1000dec
);


-- ============================================================================
-- TEST 8 — Limite minimale uniquement
-- Résultat attendu : 1500.75dec
-- ============================================================================

RETURN fn::validation_decimal(
    1500.75dec,
    "AMOUNT",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 9 — Limite maximale uniquement
-- Résultat attendu : -10.50dec
-- ============================================================================

RETURN fn::validation_decimal(
    -10.50dec,
    "BALANCE",
    NONE,
    100dec
);


-- ============================================================================
-- TEST 10 — Valeur absente
-- Erreur attendue : PRICE_REQUIRED
-- ============================================================================

RETURN fn::validation_decimal(
    NONE,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 11 — Valeur NULL
-- Erreur attendue : PRICE_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_decimal(
    NULL,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 12 — Entier à la place d'un decimal
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_decimal(
    19,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 13 — Entier zéro à la place d'un decimal
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_decimal(
    0,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 14 — Float à la place d'un decimal
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_decimal(
    19.99f,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 15 — Chaîne contenant un decimal
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_decimal(
    "19.99",
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 16 — Booléen à la place d'un decimal
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_decimal(
    true,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 17 — Tableau à la place d'un decimal
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_decimal(
    [19.99dec],
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 18 — Objet à la place d'un decimal
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_decimal(
    {
        value: 19.99dec
    },
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 19 — Valeur inférieure à la limite minimale
-- Erreur attendue : PRICE_TOO_SMALL
-- ============================================================================

RETURN fn::validation_decimal(
    -0.01dec,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 20 — Valeur supérieure à la limite maximale
-- Erreur attendue : PERCENTAGE_TOO_LARGE
-- ============================================================================

RETURN fn::validation_decimal(
    100.01dec,
    "PERCENTAGE",
    0dec,
    100dec
);


-- ============================================================================
-- TEST 21 — Plage incohérente
-- Erreur attendue : VALIDATION_INVALID_DECIMAL_RANGE
-- ============================================================================

RETURN fn::validation_decimal(
    50dec,
    "PERCENTAGE",
    100dec,
    10dec
);


-- ============================================================================
-- TEST 22 — Minimum et maximum identiques avec valeur identique
-- Résultat attendu : 50dec
-- ============================================================================

RETURN fn::validation_decimal(
    50dec,
    "VALUE",
    50dec,
    50dec
);


-- ============================================================================
-- TEST 23 — Minimum et maximum identiques avec valeur inférieure
-- Erreur attendue : VALUE_TOO_SMALL
-- ============================================================================

RETURN fn::validation_decimal(
    49.99dec,
    "VALUE",
    50dec,
    50dec
);


-- ============================================================================
-- TEST 24 — Minimum et maximum identiques avec valeur supérieure
-- Erreur attendue : VALUE_TOO_LARGE
-- ============================================================================

RETURN fn::validation_decimal(
    50.01dec,
    "VALUE",
    50dec,
    50dec
);


-- ============================================================================
-- TEST 25 — Conversion explicite d'une chaîne avant validation
-- Résultat attendu : 19.99dec
-- ============================================================================

LET $converted_price = type::decimal(
    "19.99"
);

RETURN fn::validation_decimal(
    $converted_price,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 26 — Conversion explicite d'un entier avant validation
-- Résultat attendu : 19dec
-- ============================================================================

LET $converted_price = type::decimal(
    19
);

RETURN fn::validation_decimal(
    $converted_price,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 27 — Conversion explicite d'un float avant validation
-- Résultat attendu : valeur decimal issue de 19.99f
-- ============================================================================

LET $converted_price = type::decimal(
    19.99f
);

RETURN fn::validation_decimal(
    $converted_price,
    "PRICE",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 28 — Grande valeur decimal
-- Résultat attendu : 999999999999999999.99dec
-- ============================================================================

RETURN fn::validation_decimal(
    999999999999999999.99dec,
    "AMOUNT",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 29 — Très petite valeur positive
-- Résultat attendu : 0.000001dec
-- ============================================================================

RETURN fn::validation_decimal(
    0.000001dec,
    "RATE",
    0dec,
    1dec
);


-- ============================================================================
-- TEST 30 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_decimal(
    19.99dec,
    "     ",
    0dec,
    NONE
);


-- ============================================================================
-- TEST 31 — Utilisation avec validation_unique
-- Résultat attendu : dépend du contenu de la table cible
-- Note : exemple d'enchaînement uniquement
-- ============================================================================

LET $price = fn::validation_decimal(
    19.99dec,
    "PRICE",
    0dec,
    NONE
);

RETURN $price;