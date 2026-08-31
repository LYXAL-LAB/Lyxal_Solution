-- ============================================================================
-- TEST 1 — Entier valide sans limites
-- Résultat attendu : 42
-- ============================================================================

RETURN fn::validation_integer(
    42,
    "POSITION",
    NONE,
    NONE
);

-- ============================================================================
-- TEST 2 — Entier compris dans une plage
-- Résultat attendu : 10
-- ============================================================================

RETURN fn::validation_integer(
    10,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 3 — Valeur égale à la limite minimale
-- Résultat attendu : 1
-- ============================================================================

RETURN fn::validation_integer(
    1,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 4 — Valeur égale à la limite maximale
-- Résultat attendu : 100
-- ============================================================================

RETURN fn::validation_integer(
    100,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 5 — Valeur absente
-- Erreur attendue : QUANTITY_REQUIRED
-- ============================================================================

RETURN fn::validation_integer(
    NONE,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 6 — Chaîne contenant un entier
-- Erreur attendue : QUANTITY_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_integer(
    "10",
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 7 — Nombre décimal
-- Erreur attendue : QUANTITY_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_integer(
    10.5dec,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 8 — Nombre flottant
-- Erreur attendue : QUANTITY_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_integer(
    10.5f,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 9 — Valeur inférieure à la limite minimale
-- Erreur attendue : QUANTITY_TOO_SMALL
-- ============================================================================

RETURN fn::validation_integer(
    0,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 10 — Valeur supérieure à la limite maximale
-- Erreur attendue : QUANTITY_TOO_LARGE
-- ============================================================================

RETURN fn::validation_integer(
    101,
    "QUANTITY",
    1,
    100
);

-- ============================================================================
-- TEST 11 — Entier négatif autorisé
-- Résultat attendu : -50
-- ============================================================================

RETURN fn::validation_integer(
    -50,
    "OFFSET",
    -100,
    100
);

-- ============================================================================
-- TEST 12 — Minimum uniquement
-- Résultat attendu : 500
-- ============================================================================

RETURN fn::validation_integer(
    500,
    "MAX_RETRIES",
    0,
    NONE
);

-- ============================================================================
-- TEST 13 — Maximum uniquement
-- Résultat attendu : -10
-- ============================================================================

RETURN fn::validation_integer(
    -10,
    "TEMPERATURE",
    NONE,
    100
);

-- ============================================================================
-- TEST 14 — Plage de configuration incohérente
-- Erreur attendue : VALIDATION_INVALID_INTEGER_RANGE
-- ============================================================================

RETURN fn::validation_integer(
    50,
    "QUANTITY",
    100,
    10
);

-- ============================================================================
-- TEST 15 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_integer(
    10,
    "     ",
    1,
    100
);

-- ============================================================================
-- TEST 16 — Valeur booléenne
-- Erreur attendue : QUANTITY_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_integer(
    true,
    "QUANTITY",
    1,
    100
);