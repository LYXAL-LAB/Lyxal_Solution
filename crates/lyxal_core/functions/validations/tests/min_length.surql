-- ============================================================================
-- TEST 1 — Longueur supérieure à la limite
-- Résultat attendu : "Administrateur"
-- ============================================================================

RETURN fn::validation_min_length(
    "Administrateur",
    "ROLE_LABEL",
    3
);

-- ============================================================================
-- TEST 2 — Longueur exactement égale à la limite
-- Résultat attendu : "admin"
-- ============================================================================

RETURN fn::validation_min_length(
    "admin",
    "ROLE_LABEL",
    5
);

-- ============================================================================
-- TEST 3 — Valeur trop courte
-- Erreur attendue : USERNAME_TOO_SHORT
-- ============================================================================

RETURN fn::validation_min_length(
    "ab",
    "USERNAME",
    3
);

-- ============================================================================
-- TEST 4 — Chaîne vide avec une limite supérieure à zéro
-- Erreur attendue : TITLE_TOO_SHORT
-- ============================================================================

RETURN fn::validation_min_length(
    "",
    "TITLE",
    1
);

-- ============================================================================
-- TEST 5 — Longueur minimale égale à zéro
-- Résultat attendu : ""
-- ============================================================================

RETURN fn::validation_min_length(
    "",
    "OPTIONAL_VALUE",
    0
);

-- ============================================================================
-- TEST 6 — Longueur minimale négative
-- Erreur attendue : VALIDATION_INVALID_MIN_LENGTH
-- ============================================================================

RETURN fn::validation_min_length(
    "Une valeur",
    "TITLE",
    -1
);

-- ============================================================================
-- TEST 7 — Nom technique du champ vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_min_length(
    "Une valeur",
    "    ",
    3
);