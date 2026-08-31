-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/time_range.test.surql
-- Fonction     : fn::validation_time_range
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
-- TEST 1 — Plage valide sans limites de durée
-- Résultat attendu :
-- {
--     start_at: d"2026-08-03T08:00:00Z",
--     end_at: d"2026-08-03T10:30:00Z",
--     duration: 2h30m
-- }
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:30:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Plage valide comprise entre une durée minimale et maximale
-- Résultat attendu : durée de 2h30m
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:30:00Z",
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 3 — Durée égale à la limite minimale
-- Résultat attendu : durée de 30m
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:30:00Z",
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 4 — Durée égale à la limite maximale
-- Résultat attendu : durée de 8h
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T16:00:00Z",
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 5 — Durée minimale uniquement
-- Résultat attendu : durée de 2h
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    30m,
    NONE
);


-- ============================================================================
-- TEST 6 — Durée maximale uniquement
-- Résultat attendu : durée de 2h
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    8h
);


-- ============================================================================
-- TEST 7 — Plage traversant minuit
-- Résultat attendu : durée de 4h
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T22:00:00Z",
    d"2026-08-04T02:00:00Z",
    "SESSION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 8 — Plage traversant plusieurs jours
-- Résultat attendu : durée de 2d6h
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-05T14:00:00Z",
    "EXECUTION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 9 — Plage traversant plusieurs semaines
-- Résultat attendu : durée de 3w
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-24T08:00:00Z",
    "CONTRACT_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 10 — Plage d'une nanoseconde
-- Résultat attendu : durée de 1ns
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00.000000000Z",
    d"2026-08-03T08:00:00.000000001Z",
    "EXECUTION_RANGE",
    false,
    1ns,
    NONE
);


-- ============================================================================
-- TEST 11 — Durée nulle autorisée
-- Résultat attendu : durée de 0ns
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:00:00Z",
    "MARKER_RANGE",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 12 — Durée nulle autorisée avec minimum égal à zéro
-- Résultat attendu : durée de 0ns
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:00:00Z",
    "MARKER_RANGE",
    true,
    0ns,
    1h
);


-- ============================================================================
-- TEST 13 — Durée exacte d'une heure
-- Résultat attendu : durée de 1h
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T09:00:00Z",
    "APPOINTMENT_RANGE",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 14 — Début converti depuis une chaîne
-- Résultat attendu : durée de 2h
-- ============================================================================

LET $start_at = type::datetime(
    "2026-08-03T08:00:00Z"
);

RETURN fn::validation_time_range(
    $start_at,
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Début et fin convertis depuis des chaînes
-- Résultat attendu : durée de 2h
-- ============================================================================

LET $start_at = type::datetime(
    "2026-08-03T08:00:00Z"
);

LET $end_at = type::datetime(
    "2026-08-03T10:00:00Z"
);

RETURN fn::validation_time_range(
    $start_at,
    $end_at,
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Valeurs exprimées avec des fuseaux horaires différents
-- Résultat attendu : durée réelle de 2h
-- Note :
-- 10:00 +02:00 correspond à 08:00 UTC
-- 10:00 UTC correspond à 10:00 UTC
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T10:00:00+02:00",
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Deux représentations du même instant avec durée nulle autorisée
-- Résultat attendu : durée de 0ns
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T10:00:00+02:00",
    d"2026-08-03T08:00:00Z",
    "MARKER_RANGE",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Début absent
-- Erreur attendue : BOOKING_RANGE_START_REQUIRED
-- ============================================================================

RETURN fn::validation_time_range(
    NONE,
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Début NULL
-- Erreur attendue : BOOKING_RANGE_START_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_time_range(
    NULL,
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 20 — Début sous forme de chaîne
-- Erreur attendue : BOOKING_RANGE_START_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_time_range(
    "2026-08-03T08:00:00Z",
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 21 — Début sous forme d'entier
-- Erreur attendue : BOOKING_RANGE_START_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_time_range(
    1754208000,
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 22 — Début sous forme de durée
-- Erreur attendue : BOOKING_RANGE_START_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_time_range(
    2h,
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 23 — Fin absente
-- Erreur attendue : BOOKING_RANGE_END_REQUIRED
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    NONE,
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 24 — Fin NULL
-- Erreur attendue : BOOKING_RANGE_END_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    NULL,
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 25 — Fin sous forme de chaîne
-- Erreur attendue : BOOKING_RANGE_END_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    "2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 26 — Fin sous forme d'entier
-- Erreur attendue : BOOKING_RANGE_END_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    1754215200,
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 27 — Fin sous forme de durée
-- Erreur attendue : BOOKING_RANGE_END_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    2h,
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 28 — Fin antérieure au début
-- Erreur attendue : BOOKING_RANGE_INVALID_ORDER
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T10:00:00Z",
    d"2026-08-03T08:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 29 — Fin antérieure d'une nanoseconde
-- Erreur attendue : BOOKING_RANGE_INVALID_ORDER
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00.000000001Z",
    d"2026-08-03T08:00:00.000000000Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 30 — Durée nulle interdite
-- Erreur attendue : BOOKING_RANGE_ZERO_DURATION_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 31 — Durée nulle autorisée mais minimum positif
-- Erreur attendue : MARKER_RANGE_DURATION_TOO_SHORT
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:00:00Z",
    "MARKER_RANGE",
    true,
    1ns,
    NONE
);


-- ============================================================================
-- TEST 32 — Durée inférieure au minimum
-- Erreur attendue : BOOKING_RANGE_DURATION_TOO_SHORT
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:29:59Z",
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 33 — Durée inférieure au minimum d'une nanoseconde
-- Erreur attendue : BOOKING_RANGE_DURATION_TOO_SHORT
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00.000000000Z",
    d"2026-08-03T08:29:59.999999999Z",
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 34 — Durée supérieure au maximum
-- Erreur attendue : BOOKING_RANGE_DURATION_TOO_LONG
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T16:00:01Z",
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 35 — Durée supérieure au maximum d'une nanoseconde
-- Erreur attendue : BOOKING_RANGE_DURATION_TOO_LONG
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00.000000000Z",
    d"2026-08-03T16:00:00.000000001Z",
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 36 — Durée exacte non respectée par défaut
-- Erreur attendue : APPOINTMENT_RANGE_DURATION_TOO_SHORT
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:59:59Z",
    "APPOINTMENT_RANGE",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 37 — Durée exacte dépassée
-- Erreur attendue : APPOINTMENT_RANGE_DURATION_TOO_LONG
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T09:00:01Z",
    "APPOINTMENT_RANGE",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 38 — Plage de durées incohérente
-- Erreur attendue : VALIDATION_INVALID_TIME_RANGE_DURATION
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:00:00Z",
    "BOOKING_RANGE",
    false,
    8h,
    1h
);


-- ============================================================================
-- TEST 39 — Configuration impossible avec durée nulle interdite
-- Erreur attendue : VALIDATION_IMPOSSIBLE_TIME_RANGE
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:00:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 40 — Maximum nul accepté lorsque la durée nulle est autorisée
-- Résultat attendu : durée de 0ns
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:00:00Z",
    "MARKER_RANGE",
    true,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 41 — Minimum et maximum nuls avec durée nulle autorisée
-- Résultat attendu : durée de 0ns
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T08:00:00Z",
    "MARKER_RANGE",
    true,
    0ns,
    0ns
);


-- ============================================================================
-- TEST 42 — Extraction du datetime de début
-- Résultat attendu : d"2026-08-03T08:00:00Z"
-- ============================================================================

LET $range = fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:30:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);

RETURN $range.start_at;


-- ============================================================================
-- TEST 43 — Extraction du datetime de fin
-- Résultat attendu : d"2026-08-03T10:30:00Z"
-- ============================================================================

LET $range = fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:30:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);

RETURN $range.end_at;


-- ============================================================================
-- TEST 44 — Extraction de la durée
-- Résultat attendu : 2h30m
-- ============================================================================

LET $range = fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:30:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);

RETURN $range.duration;


-- ============================================================================
-- TEST 45 — Conversion de la durée en minutes
-- Résultat attendu : 150
-- ============================================================================

LET $range = fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:30:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);

RETURN duration::mins(
    $range.duration
);


-- ============================================================================
-- TEST 46 — Conversion de la durée en secondes
-- Résultat attendu : 9000
-- ============================================================================

LET $range = fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:30:00Z",
    "BOOKING_RANGE",
    false,
    NONE,
    NONE
);

RETURN duration::secs(
    $range.duration
);


-- ============================================================================
-- TEST 47 — Validation d'une plage future construite dynamiquement
-- Résultat attendu : durée de 2h
-- ============================================================================

LET $start_at = time::now() + 1h;
LET $end_at = $start_at + 2h;

RETURN fn::validation_time_range(
    $start_at,
    $end_at,
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 48 — Validation d'une plage passée
-- Résultat attendu : durée de 4h
-- ============================================================================

LET $end_at = time::now() - 1h;
LET $start_at = $end_at - 4h;

RETURN fn::validation_time_range(
    $start_at,
    $end_at,
    "EXECUTION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 49 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_time_range(
    d"2026-08-03T08:00:00Z",
    d"2026-08-03T10:00:00Z",
    "     ",
    false,
    NONE,
    NONE
);