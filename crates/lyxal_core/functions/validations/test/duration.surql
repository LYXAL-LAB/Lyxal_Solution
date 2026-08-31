-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/duration.test.surql
-- Fonction     : fn::validation_duration
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc.
--
-- Dans Surrealist, sélectionner uniquement le test concerné lorsqu'une erreur
-- est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Durée valide en secondes
-- Résultat attendu : 30s
-- ============================================================================

RETURN fn::validation_duration(
    30s,
    "TIMEOUT",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Durée valide en minutes
-- Résultat attendu : 15m
-- ============================================================================

RETURN fn::validation_duration(
    15m,
    "SESSION_DURATION",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 3 — Durée composée valide
-- Résultat attendu : 2h30m
-- ============================================================================

RETURN fn::validation_duration(
    2h30m,
    "BOOKING_DURATION",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 4 — Durée valide en jours
-- Résultat attendu : 3d
-- ============================================================================

RETURN fn::validation_duration(
    3d,
    "RETENTION_PERIOD",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 5 — Durée valide en semaines
-- Résultat attendu : 2w
-- ============================================================================

RETURN fn::validation_duration(
    2w,
    "RETENTION_PERIOD",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 6 — Durée nulle valide sans minimum positif
-- Résultat attendu : 0ns
-- ============================================================================

RETURN fn::validation_duration(
    0ns,
    "DELAY",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 7 — Durée comprise dans une plage
-- Résultat attendu : 30m
-- ============================================================================

RETURN fn::validation_duration(
    30m,
    "SESSION_DURATION",
    5m,
    24h
);


-- ============================================================================
-- TEST 8 — Durée égale à la limite minimale
-- Résultat attendu : 5m
-- ============================================================================

RETURN fn::validation_duration(
    5m,
    "SESSION_DURATION",
    5m,
    24h
);


-- ============================================================================
-- TEST 9 — Durée égale à la limite maximale
-- Résultat attendu : 24h
-- ============================================================================

RETURN fn::validation_duration(
    24h,
    "SESSION_DURATION",
    5m,
    24h
);


-- ============================================================================
-- TEST 10 — Minimum uniquement
-- Résultat attendu : 10m
-- ============================================================================

RETURN fn::validation_duration(
    10m,
    "RETRY_DELAY",
    1s,
    NONE
);


-- ============================================================================
-- TEST 11 — Maximum uniquement
-- Résultat attendu : 2h
-- ============================================================================

RETURN fn::validation_duration(
    2h,
    "BOOKING_DURATION",
    NONE,
    24h
);


-- ============================================================================
-- TEST 12 — Durées équivalentes avec unités différentes
-- Résultat attendu : 60m ou représentation canonique équivalente
-- ============================================================================

RETURN fn::validation_duration(
    60m,
    "DURATION",
    1h,
    1h
);


-- ============================================================================
-- TEST 13 — Valeur absente
-- Erreur attendue : TIMEOUT_REQUIRED
-- ============================================================================

RETURN fn::validation_duration(
    NONE,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 14 — Valeur NULL
-- Erreur attendue : TIMEOUT_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_duration(
    NULL,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 15 — Chaîne contenant une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    "30s",
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 16 — Entier à la place d'une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    30,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 17 — Float à la place d'une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    30f,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 18 — Decimal à la place d'une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    30dec,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 19 — Datetime à la place d'une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    d"2026-08-03T10:00:00Z",
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 20 — Booléen à la place d'une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    true,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 21 — Tableau à la place d'une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    [30s],
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 22 — Objet à la place d'une durée
-- Erreur attendue : TIMEOUT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration(
    {
        value: 30s
    },
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 23 — Durée inférieure à la limite minimale
-- Erreur attendue : TIMEOUT_TOO_SHORT
-- ============================================================================

RETURN fn::validation_duration(
    500ms,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 24 — Durée supérieure à la limite maximale
-- Erreur attendue : TIMEOUT_TOO_LONG
-- ============================================================================

RETURN fn::validation_duration(
    6m,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 25 — Durée nulle refusée par un minimum positif
-- Erreur attendue : TIMEOUT_TOO_SHORT
-- ============================================================================

RETURN fn::validation_duration(
    0ns,
    "TIMEOUT",
    1ns,
    NONE
);


-- ============================================================================
-- TEST 26 — Plage incohérente
-- Erreur attendue : VALIDATION_INVALID_DURATION_RANGE
-- ============================================================================

RETURN fn::validation_duration(
    1h,
    "DURATION",
    2h,
    30m
);


-- ============================================================================
-- TEST 27 — Minimum et maximum identiques
-- Résultat attendu : 30m
-- ============================================================================

RETURN fn::validation_duration(
    30m,
    "DURATION",
    30m,
    30m
);


-- ============================================================================
-- TEST 28 — Valeur inférieure à une plage exacte
-- Erreur attendue : DURATION_TOO_SHORT
-- ============================================================================

RETURN fn::validation_duration(
    29m59s,
    "DURATION",
    30m,
    30m
);


-- ============================================================================
-- TEST 29 — Valeur supérieure à une plage exacte
-- Erreur attendue : DURATION_TOO_LONG
-- ============================================================================

RETURN fn::validation_duration(
    30m1s,
    "DURATION",
    30m,
    30m
);


-- ============================================================================
-- TEST 30 — Conversion explicite d'une chaîne
-- Résultat attendu : 2h30m
-- ============================================================================

LET $converted_duration = type::duration(
    "2h30m"
);

RETURN fn::validation_duration(
    $converted_duration,
    "BOOKING_DURATION",
    1m,
    24h
);


-- ============================================================================
-- TEST 31 — Conversion explicite d'une durée déjà typée
-- Résultat attendu : 30s
-- ============================================================================

LET $converted_duration = type::duration(
    30s
);

RETURN fn::validation_duration(
    $converted_duration,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 32 — Durée construite depuis des secondes
-- Résultat attendu : 2m
-- ============================================================================

LET $converted_duration = duration::from_secs(
    120
);

RETURN fn::validation_duration(
    $converted_duration,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 33 — Durée construite depuis des millisecondes
-- Résultat attendu : 1500ms ou représentation canonique équivalente
-- ============================================================================

LET $converted_duration = duration::from_millis(
    1500
);

RETURN fn::validation_duration(
    $converted_duration,
    "TIMEOUT",
    1s,
    5m
);


-- ============================================================================
-- TEST 34 — Durée composée avec précision fine
-- Résultat attendu : 1h30m20s500ms
-- ============================================================================

RETURN fn::validation_duration(
    1h30m20s500ms,
    "DURATION",
    1h,
    2h
);


-- ============================================================================
-- TEST 35 — Utilisation pour calculer un datetime futur
-- Résultat attendu : datetime environ trente minutes après $current_datetime
-- ============================================================================

LET $current_datetime = time::now();

LET $ttl = fn::validation_duration(
    30m,
    "TTL",
    1s,
    24h
);

RETURN $current_datetime + $ttl;


-- ============================================================================
-- TEST 36 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_duration(
    30m,
    "     ",
    1s,
    24h
);


-- ============================================================================
-- TEST 37 — Validation de duration::max
-- Résultat attendu : duration::max
-- ============================================================================

RETURN fn::validation_duration(
    duration::max,
    "MAX_DURATION",
    NONE,
    duration::max
);