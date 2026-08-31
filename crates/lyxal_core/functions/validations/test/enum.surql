-- ============================================================================
-- TEST 1 — Valeur valide, comparaison insensible à la casse
-- Résultat attendu : "admin"
-- ============================================================================

RETURN fn::validation_enum(
    " ADMIN ",
    "TEAM_ROLE",
    ["owner", "admin", "member"],
    false
);

-- ============================================================================
-- TEST 2 — Valeur valide, comparaison sensible à la casse
-- Résultat attendu : "Admin"
-- ============================================================================

RETURN fn::validation_enum(
    "Admin",
    "ROLE_LABEL",
    ["Admin", "Member"],
    true
);

-- ============================================================================
-- TEST 3 — Mauvaise casse en mode sensible
-- Erreur attendue : ROLE_LABEL_INVALID
-- ============================================================================

RETURN fn::validation_enum(
    "admin",
    "ROLE_LABEL",
    ["Admin", "Member"],
    true
);

-- ============================================================================
-- TEST 4 — Valeur absente
-- Erreur attendue : TEAM_ROLE_REQUIRED
-- ============================================================================

RETURN fn::validation_enum(
    NONE,
    "TEAM_ROLE",
    ["owner", "admin", "member"],
    false
);

-- ============================================================================
-- TEST 5 — Chaîne vide
-- Erreur attendue : TEAM_ROLE_REQUIRED
-- ============================================================================

RETURN fn::validation_enum(
    "   ",
    "TEAM_ROLE",
    ["owner", "admin", "member"],
    false
);

-- ============================================================================
-- TEST 6 — Valeur non autorisée
-- Erreur attendue : TEAM_ROLE_INVALID
-- ============================================================================

RETURN fn::validation_enum(
    "superhero",
    "TEAM_ROLE",
    ["owner", "admin", "member"],
    false
);

-- ============================================================================
-- TEST 7 — Liste des valeurs autorisées vide
-- Erreur attendue : VALIDATION_EMPTY_ALLOWED_VALUES
-- ============================================================================

RETURN fn::validation_enum(
    "admin",
    "TEAM_ROLE",
    [],
    false
);

-- ============================================================================
-- TEST 8 — Valeur autorisée vide
-- Erreur attendue : VALIDATION_INVALID_ALLOWED_VALUE
-- ============================================================================

RETURN fn::validation_enum(
    "admin",
    "TEAM_ROLE",
    ["owner", "   ", "member"],
    false
);