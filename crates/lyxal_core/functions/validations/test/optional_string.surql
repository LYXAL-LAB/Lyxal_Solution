-- ============================================================================
-- TEST 1 — Valeur absente
-- Résultat attendu : NONE
-- ============================================================================

RETURN fn::validation_optional_string(
    NONE,
    "TEAM_DESCRIPTION",
    NONE,
    500
);

-- ============================================================================
-- TEST 2 — Chaîne vide
-- Résultat attendu : NONE
-- ============================================================================

RETURN fn::validation_optional_string(
    "",
    "TEAM_DESCRIPTION",
    NONE,
    500
);

-- ============================================================================
-- TEST 3 — Chaîne composée uniquement d'espaces
-- Résultat attendu : NONE
-- ============================================================================

RETURN fn::validation_optional_string(
    "       ",
    "TEAM_DESCRIPTION",
    NONE,
    500
);

-- ============================================================================
-- TEST 4 — Valeur valide avec espaces périphériques
-- Résultat attendu : "Équipe responsable des rendez-vous commerciaux"
-- ============================================================================

RETURN fn::validation_optional_string(
    "   Équipe responsable des rendez-vous commerciaux   ",
    "TEAM_DESCRIPTION",
    NONE,
    500
);

-- ============================================================================
-- TEST 5 — Chaîne trop courte
-- Erreur attendue : EVENT_SUBTITLE_TOO_SHORT
-- ============================================================================

RETURN fn::validation_optional_string(
    "AB",
    "EVENT_SUBTITLE",
    3,
    150
);

-- Erreur attendue : TEAM_DESCRIPTION_TOO_LONG

-- ============================================================================
-- TEST 6 — Chaîne trop longue
-- Erreur attendue : TEAM_DESCRIPTION_TOO_LONG
-- ============================================================================

RETURN fn::validation_optional_string(
    "Cette description dépasse volontairement la limite autorisée.",
    "TEAM_DESCRIPTION",
    NONE,
    20
);

-- ============================================================================
-- TEST 7 — Configuration incohérente
-- Erreur attendue : VALIDATION_INVALID_LENGTH_RANGE
-- ============================================================================

RETURN fn::validation_optional_string(
    "Une valeur",
    "TEAM_DESCRIPTION",
    500,
    100
);

