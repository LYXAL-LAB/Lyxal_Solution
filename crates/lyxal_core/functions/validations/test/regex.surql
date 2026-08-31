-- ============================================================================
-- TEST 1 — Slug valide
-- Résultat attendu : "equipe-commerciale"
-- ============================================================================

RETURN fn::validation_regex(
    "  equipe-commerciale  ",
    "TEAM_SLUG",
    "^[a-z0-9]+(?:-[a-z0-9]+)*$"
);

-- ============================================================================
-- TEST 2 — Slug invalide
-- Erreur attendue : TEAM_SLUG_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_regex(
    "Équipe Commerciale",
    "TEAM_SLUG",
    "^[a-z0-9]+(?:-[a-z0-9]+)*$"
);

-- ============================================================================
-- TEST 3 — Code postal valide
-- Résultat attendu : "75001"
-- ============================================================================

RETURN fn::validation_regex(
    "75001",
    "POSTAL_CODE",
    "^[0-9]{5}$"
);

-- ============================================================================
-- TEST 4 — Code postal invalide
-- Erreur attendue : POSTAL_CODE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_regex(
    "7500",
    "POSTAL_CODE",
    "^[0-9]{5}$"
);

-- ============================================================================
-- TEST 5 — Username valide
-- Résultat attendu : "yaniss_d"
-- ============================================================================

RETURN fn::validation_regex(
    "yaniss_d",
    "USERNAME",
    "^[a-zA-Z0-9_-]{3,50}$"
);

-- ============================================================================
-- TEST 6 — Valeur absente
-- Erreur attendue : USERNAME_REQUIRED
-- ============================================================================

RETURN fn::validation_regex(
    NONE,
    "USERNAME",
    "^[a-zA-Z0-9_-]{3,50}$"
);

-- ============================================================================
-- TEST 7 — Valeur vide
-- Erreur attendue : USERNAME_REQUIRED
-- ============================================================================

RETURN fn::validation_regex(
    "     ",
    "USERNAME",
    "^[a-zA-Z0-9_-]{3,50}$"
);

-- ============================================================================
-- TEST 8 — Motif vide
-- Erreur attendue : VALIDATION_EMPTY_REGEX_PATTERN
-- ============================================================================

RETURN fn::validation_regex(
    "une-valeur",
    "SLUG",
    "     "
);

-- ============================================================================
-- TEST 9 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_regex(
    "une-valeur",
    "    ",
    "^[a-z-]+$"
);