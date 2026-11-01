-- ============================================================================
-- TEST 1 — Identifiant simple valide
-- Résultat attendu : booking_team:team_001
-- ============================================================================

RETURN fn::validation_record(
    "team_001",
    "TEAM_ID",
    "booking_team"
);

-- ============================================================================
-- TEST 2 — Record ID complet valide
-- Résultat attendu : booking_team:team_001
-- ============================================================================

RETURN fn::validation_record(
    "booking_team:team_001",
    "TEAM_ID",
    "booking_team"
);

-- ============================================================================
-- TEST 3 — Valeur absente
-- Erreur attendue : TEAM_ID_REQUIRED
-- ============================================================================

RETURN fn::validation_record(
    NONE,
    "TEAM_ID",
    "booking_team"
);

-- ============================================================================
-- TEST 4 — Mauvaise table
-- Erreur attendue : TEAM_ID_INVALID_TABLE
-- ============================================================================

RETURN fn::validation_record(
    "identity_user:user_001",
    "TEAM_ID",
    "booking_team"
);

-- ============================================================================
-- TEST 5 — Identifiant vide
-- Erreur attendue : TEAM_ID_INVALID
-- ============================================================================

RETURN fn::validation_record(
    "booking_team:",
    "TEAM_ID",
    "booking_team"
);

-- ============================================================================
-- TEST 6 — Format ambigu
-- Erreur attendue : TEAM_ID_INVALID
-- ============================================================================

RETURN fn::validation_record(
    "booking_team:team:001",
    "TEAM_ID",
    "booking_team"
);
