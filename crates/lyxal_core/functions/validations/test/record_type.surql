-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/record_type.test.surql
-- Fonction     : fn::validation_record_type
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc. Dans Surrealist, sélectionner uniquement le test à exécuter lorsque
-- celui-ci attend une erreur.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Record ID d'équipe valide
-- Résultat attendu : booking_team:team_001
-- ============================================================================

RETURN fn::validation_record_type(
    booking_team:team_001,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 2 — Record ID utilisateur valide
-- Résultat attendu : identity_user:user_001
-- ============================================================================

RETURN fn::validation_record_type(
    identity_user:user_001,
    "USER_ID",
    "identity_user"
);


-- ============================================================================
-- TEST 3 — Record ID avec identifiant numérique
-- Résultat attendu : booking_team:123
-- ============================================================================

RETURN fn::validation_record_type(
    booking_team:123,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 4 — Record ID construit avec type::record()
-- Résultat attendu : booking_team:team_001
-- ============================================================================

LET $team_id = type::record(
    "booking_team",
    "team_001"
);

RETURN fn::validation_record_type(
    $team_id,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 5 — Record ID provenant de validation_record()
-- Résultat attendu : booking_team:team_001
-- ============================================================================

LET $team_id = fn::validation_record(
    "team_001",
    "TEAM_ID",
    "booking_team"
);

RETURN fn::validation_record_type(
    $team_id,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 6 — Valeur absente
-- Erreur attendue : TEAM_ID_REQUIRED
-- ============================================================================

RETURN fn::validation_record_type(
    NONE,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 7 — Valeur NULL
-- Erreur attendue : TEAM_ID_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_record_type(
    NULL,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 8 — Chaîne Record ID au lieu d'un Record ID natif
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    "booking_team:team_001",
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 9 — Identifiant simple sous forme de chaîne
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    "team_001",
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 10 — Record ID appartenant à une autre table
-- Erreur attendue : TEAM_ID_INVALID_TABLE
-- ============================================================================

RETURN fn::validation_record_type(
    identity_user:user_001,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 11 — Entier à la place d'un Record ID
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    123,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 12 — UUID à la place d'un Record ID
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 13 — Objet à la place d'un Record ID
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    {
        id: booking_team:team_001
    },
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 14 — Tableau à la place d'un Record ID
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    [
        booking_team:team_001
    ],
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 15 — Booléen à la place d'un Record ID
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    true,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 16 — Datetime à la place d'un Record ID
-- Erreur attendue : TEAM_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_record_type(
    d"2026-08-03T10:00:00Z",
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 17 — Nom de table attendu avec espaces périphériques
-- Résultat attendu : booking_team:team_001
-- ============================================================================

RETURN fn::validation_record_type(
    booking_team:team_001,
    "TEAM_ID",
    "   booking_team   "
);


-- ============================================================================
-- TEST 18 — Nom de table attendu vide
-- Erreur attendue : VALIDATION_INVALID_TABLE_NAME
-- ============================================================================

RETURN fn::validation_record_type(
    booking_team:team_001,
    "TEAM_ID",
    "     "
);


-- ============================================================================
-- TEST 19 — Nom technique du champ vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_record_type(
    booking_team:team_001,
    "     ",
    "booking_team"
);


-- ============================================================================
-- TEST 20 — Record ID valide mais enregistrement inexistant
-- Résultat attendu : booking_team:record_not_created
-- Note : cette fonction ne vérifie pas l'existence
-- ============================================================================

RETURN fn::validation_record_type(
    booking_team:record_not_created,
    "TEAM_ID",
    "booking_team"
);


-- ============================================================================
-- TEST 21 — Validation du type puis contrôle d'existence
-- Résultat attendu : dépend de l'existence de booking_team:team_001
-- ============================================================================

LET $team_id = fn::validation_record_type(
    booking_team:team_001,
    "TEAM_ID",
    "booking_team"
);

RETURN fn::validation_record_exists(
    $team_id,
    "TEAM_ID"
);