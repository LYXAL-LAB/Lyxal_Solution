-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/datetime.test.surql
-- Fonction     : fn::validation_datetime
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc lorsqu'ils sont exécutés avec les autres requêtes.
--
-- Dans Surrealist, sélectionner uniquement le test à exécuter lorsque celui-ci
-- attend une erreur.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Datetime valide sans limites
-- Résultat attendu : d"2026-08-01T10:00:00Z"
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-01T10:00:00Z",
    "PUBLISHED_AT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Datetime valide compris dans une plage
-- Résultat attendu : d"2026-08-15T14:30:00Z"
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-15T14:30:00Z",
    "START_AT",
    d"2026-08-01T00:00:00Z",
    d"2026-08-31T23:59:59Z"
);


-- ============================================================================
-- TEST 3 — Valeur égale à la limite minimale
-- Résultat attendu : d"2026-08-01T00:00:00Z"
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-01T00:00:00Z",
    "START_AT",
    d"2026-08-01T00:00:00Z",
    d"2026-08-31T23:59:59Z"
);


-- ============================================================================
-- TEST 4 — Valeur égale à la limite maximale
-- Résultat attendu : d"2026-08-31T23:59:59Z"
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-31T23:59:59Z",
    "END_AT",
    d"2026-08-01T00:00:00Z",
    d"2026-08-31T23:59:59Z"
);


-- ============================================================================
-- TEST 5 — Valeur absente
-- Erreur attendue : START_AT_REQUIRED
-- ============================================================================

RETURN fn::validation_datetime(
    NONE,
    "START_AT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 6 — Chaîne ISO 8601 au lieu d'un datetime
-- Erreur attendue : START_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_datetime(
    "2026-08-01T10:00:00Z",
    "START_AT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 7 — Timestamp entier au lieu d'un datetime
-- Erreur attendue : START_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_datetime(
    1785578400,
    "START_AT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 8 — Durée au lieu d'un datetime
-- Erreur attendue : START_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_datetime(
    2h30m,
    "START_AT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 9 — Valeur antérieure à la limite minimale
-- Erreur attendue : START_AT_TOO_EARLY
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-07-31T23:59:59Z",
    "START_AT",
    d"2026-08-01T00:00:00Z",
    NONE
);


-- ============================================================================
-- TEST 10 — Valeur postérieure à la limite maximale
-- Erreur attendue : END_AT_TOO_LATE
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-09-01T00:00:00Z",
    "END_AT",
    NONE,
    d"2026-08-31T23:59:59Z"
);


-- ============================================================================
-- TEST 11 — Limite minimale uniquement
-- Résultat attendu : d"2026-08-10T10:00:00Z"
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-10T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-01T00:00:00Z",
    NONE
);


-- ============================================================================
-- TEST 12 — Limite maximale uniquement
-- Résultat attendu : d"2026-08-10T10:00:00Z"
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-10T10:00:00Z",
    "EXPIRES_AT",
    NONE,
    d"2026-08-31T23:59:59Z"
);


-- ============================================================================
-- TEST 13 — Plage temporelle incohérente
-- Erreur attendue : VALIDATION_INVALID_DATETIME_RANGE
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-15T10:00:00Z",
    "START_AT",
    d"2026-08-31T23:59:59Z",
    d"2026-08-01T00:00:00Z"
);


-- ============================================================================
-- TEST 14 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_datetime(
    d"2026-08-01T10:00:00Z",
    "     ",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Validation par rapport à la date actuelle
-- Résultat attendu : datetime situé environ une heure après l'exécution
-- ============================================================================

LET $current_datetime = time::now();
LET $future_datetime = $current_datetime + 1h;

RETURN fn::validation_datetime(
    $future_datetime,
    "SCHEDULED_AT",
    $current_datetime,
    NONE
);