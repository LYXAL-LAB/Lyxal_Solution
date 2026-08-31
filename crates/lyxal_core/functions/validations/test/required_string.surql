-- ============================================================================
-- TEST 1 — Valeur valide avec espaces périphériques
-- Résultat attendu : "Équipe commerciale"
-- ============================================================================

RETURN fn::validation_required_string(
    "   Équipe commerciale   ",
    "TEAM_NAME",
    1,
    100
);

-- ============================================================================
-- TEST 2 — Valeur absente
-- Erreur attendue : TEAM_NAME_REQUIRED
-- ============================================================================

RETURN fn::validation_required_string(
    NONE,
    "TEAM_NAME",
    1,
    100
);

-- ============================================================================
-- TEST 3 — Chaîne composée uniquement d'espaces
-- Erreur attendue : TEAM_NAME_REQUIRED
-- ============================================================================

RETURN fn::validation_required_string(
    "     ",
    "TEAM_NAME",
    1,
    100
);

-- ============================================================================
-- TEST 4 — Chaîne trop courte
-- Erreur attendue : PASSWORD_TOO_SHORT
-- ============================================================================

RETURN fn::validation_required_string(
    "abc",
    "PASSWORD",
    12,
    128
);

-- ============================================================================
-- TEST 5 — Chaîne trop longue
-- Erreur attendue : TEAM_NAME_TOO_LONG
-- ============================================================================

RETURN fn::validation_required_string(
    "Une valeur volontairement trop longue",
    "TEAM_NAME",
    1,
    10
);

-- ============================================================================
-- TEST 6 — Configuration incohérente
-- Erreur attendue : VALIDATION_INVALID_LENGTH_RANGE
-- ============================================================================

RETURN fn::validation_required_string(
    "Test",
    "TEAM_NAME",
    100,
    10
);