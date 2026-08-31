-- ============================================================================
-- TEST 1 — Longueur inférieure à la limite
-- Résultat attendu : "Équipe commerciale"
-- ============================================================================

RETURN fn::validation_max_length(
    "Équipe commerciale",
    "TEAM_NAME",
    100
);

-- ============================================================================
-- TEST 2 — Longueur exactement égale à la limite
-- Résultat attendu : "admin"
-- ============================================================================

RETURN fn::validation_max_length(
    "admin",
    "ROLE_LABEL",
    5
);

-- ============================================================================
-- TEST 3 — Valeur trop longue
-- Erreur attendue : USERNAME_TOO_LONG
-- ============================================================================

RETURN fn::validation_max_length(
    "administrateur",
    "USERNAME",
    5
);

-- ============================================================================
-- TEST 4 — Chaîne vide avec limite égale à zéro
-- Résultat attendu : ""
-- ============================================================================

RETURN fn::validation_max_length(
    "",
    "EMPTY_VALUE",
    0
);

-- ============================================================================
-- TEST 5 — Chaîne non vide avec limite égale à zéro
-- Erreur attendue : VALUE_TOO_LONG
-- ============================================================================

RETURN fn::validation_max_length(
    "a",
    "VALUE",
    0
);

-- ============================================================================
-- TEST 6 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_max_length(
    "Une valeur",
    "TITLE",
    -1
);

-- ============================================================================
-- TEST 7 — Nom technique du champ vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_max_length(
    "Une valeur",
    "     ",
    100
);