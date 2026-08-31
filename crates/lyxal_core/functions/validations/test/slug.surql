-- ============================================================================
-- TEST 1 — Slug simple valide
-- Résultat attendu : "booking"
-- ============================================================================

RETURN fn::validation_slug(
    "booking",
    "MODULE_SLUG",
    100
);

-- ============================================================================
-- TEST 2 — Normalisation des majuscules et espaces
-- Résultat attendu : "equipe-commerciale"
-- ============================================================================

RETURN fn::validation_slug(
    "   Equipe-Commerciale   ",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 3 — Slug avec chiffres
-- Résultat attendu : "booking-v2"
-- ============================================================================

RETURN fn::validation_slug(
    "Booking-V2",
    "MODULE_SLUG",
    100
);

-- ============================================================================
-- TEST 4 — Valeur absente
-- Erreur attendue : TEAM_SLUG_REQUIRED
-- ============================================================================

RETURN fn::validation_slug(
    NONE,
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 5 — Valeur vide
-- Erreur attendue : TEAM_SLUG_REQUIRED
-- ============================================================================

RETURN fn::validation_slug(
    "      ",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 6 — Espace interne
-- Erreur attendue : TEAM_SLUG_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_slug(
    "equipe commerciale",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 7 — Tiret au début
-- Erreur attendue : TEAM_SLUG_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_slug(
    "-equipe-commerciale",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 8 — Tiret à la fin
-- Erreur attendue : TEAM_SLUG_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_slug(
    "equipe-commerciale-",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 9 — Deux tirets consécutifs
-- Erreur attendue : TEAM_SLUG_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_slug(
    "equipe--commerciale",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 10 — Underscore interdit
-- Erreur attendue : TEAM_SLUG_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_slug(
    "equipe_commerciale",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 11 — Caractère accentués
-- Erreur attendue : TEAM_SLUG_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_slug(
    "équipe-commerciale",
    "TEAM_SLUG",
    100
);

-- ============================================================================
-- TEST 12 — Slug trop long
-- Erreur attendue : TEAM_SLUG_TOO_LONG
-- ============================================================================

RETURN fn::validation_slug(
    "une-equipe-commerciale-avec-un-nom-tres-long",
    "TEAM_SLUG",
    20
);

-- ============================================================================
-- TEST 13 — Longueur maximale désactivée
-- Résultat attendu : "une-categorie-valide"
-- ============================================================================

RETURN fn::validation_slug(
    "une-categorie-valide",
    "CATEGORY_SLUG",
    NONE
);

-- ============================================================================
-- TEST 14 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_slug(
    "booking",
    "MODULE_SLUG",
    -1
);