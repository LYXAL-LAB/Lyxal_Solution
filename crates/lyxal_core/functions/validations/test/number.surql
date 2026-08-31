-- ============================================================================
-- TEST 1 — Entier valide sans limites
-- Résultat attendu : 42
-- ============================================================================

RETURN fn::validation_number(
    42,
    "VALUE",
    NONE,
    NONE
);

-- ============================================================================
-- TEST 2 — Nombre flottant valide
-- Résultat attendu : 42.5f
-- ============================================================================

RETURN fn::validation_number(
    42.5f,
    "VALUE",
    NONE,
    NONE
);

-- ============================================================================
-- TEST 3 — Nombre décimal valide
-- Résultat attendu : 19.99dec
-- ============================================================================

RETURN fn::validation_number(
    19.99dec,
    "PRICE",
    0,
    NONE
);

-- ============================================================================
-- TEST 4 — Valeur comprise dans une plage
-- Résultat attendu : 50.5dec
-- ============================================================================

RETURN fn::validation_number(
    50.5dec,
    "PERCENTAGE",
    0,
    100
);

-- ============================================================================
-- TEST 5 — Valeur égale à la limite minimale
-- Résultat attendu : 0
-- ============================================================================

RETURN fn::validation_number(
    0,
    "PERCENTAGE",
    0,
    100
);

-- ============================================================================
-- TEST 6 — Valeur égale à la limite maximale
-- Résultat attendu : 100
-- ============================================================================

RETURN fn::validation_number(
    100,
    "PERCENTAGE",
    0,
    100
);

-- ============================================================================
-- TEST 7 — Valeur absente
-- Erreur attendue : PRICE_REQUIRED
-- ============================================================================

RETURN fn::validation_number(
    NONE,
    "PRICE",
    0,
    NONE
);

-- ============================================================================
-- TEST 8 — Chaîne contenant un nombre
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_number(
    "19.99",
    "PRICE",
    0,
    NONE
);

-- ============================================================================
-- TEST 9 — Valeur booléenne
-- Erreur attendue : PRICE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_number(
    true,
    "PRICE",
    0,
    NONE
);

-- ============================================================================
-- TEST 10 — Valeur inférieure à la limite minimale
-- Erreur attendue : PRICE_TOO_SMALL
-- ============================================================================

RETURN fn::validation_number(
    -0.01dec,
    "PRICE",
    0,
    NONE
);

-- ============================================================================
-- TEST 11 — Valeur supérieure à la limite maximale
-- Erreur attendue : PERCENTAGE_TOO_LARGE
-- ============================================================================

RETURN fn::validation_number(
    100.01dec,
    "PERCENTAGE",
    0,
    100
);

-- ============================================================================
-- TEST 12 — Nombre négatif autorisé
-- Résultat attendu : -25.5f
-- ============================================================================

RETURN fn::validation_number(
    -25.5f,
    "TEMPERATURE",
    -100,
    100
);

-- ============================================================================
-- TEST 13 — Limite minimale uniquement
-- Résultat attendu : 1500.75dec
-- ============================================================================

RETURN fn::validation_number(
    1500.75dec,
    "AMOUNT",
    0,
    NONE
);

-- ============================================================================
-- TEST 14 — Limite maximale uniquement
-- Résultat attendu : -10.5f
-- ============================================================================

RETURN fn::validation_number(
    -10.5f,
    "TEMPERATURE",
    NONE,
    50
);

-- ============================================================================
-- TEST 15 — Plage de configuration incohérente
-- Erreur attendue : VALIDATION_INVALID_NUMBER_RANGE
-- ============================================================================

RETURN fn::validation_number(
    50,
    "PERCENTAGE",
    100,
    10
);

-- ============================================================================
-- TEST 16 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_number(
    19.99dec,
    "     ",
    0,
    NONE
);

-- ============================================================================
-- TEST 17 — Comparaison entre un decimal et des limites int
-- Résultat attendu : 49.95dec
-- ============================================================================

RETURN fn::validation_number(
    49.95dec,
    "PRICE",
    0,
    100
);

-- ============================================================================
-- TEST 18 — Comparaison entre un float et des limites decimal
-- Résultat attendu : 25.5f
-- ============================================================================

RETURN fn::validation_number(
    25.5f,
    "RATE",
    0dec,
    100dec
);

