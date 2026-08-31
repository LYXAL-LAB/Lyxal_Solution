-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/duration_range.test.surql
-- Fonction     : fn::validation_duration_range
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
-- TEST 1 — Plage de durées valide
-- Résultat attendu :
-- {
--     min_duration: 30m,
--     max_duration: 8h,
--     span: 7h30m
-- }
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Plage valide avec limites d'étendue
-- Résultat attendu : étendue de 7h30m
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    1h,
    24h
);


-- ============================================================================
-- TEST 3 — Étendue égale à la limite minimale
-- Résultat attendu : étendue de 1h
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    1h30m,
    "DURATION_RANGE",
    false,
    1h,
    8h
);


-- ============================================================================
-- TEST 4 — Étendue égale à la limite maximale
-- Résultat attendu : étendue de 8h
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h30m,
    "DURATION_RANGE",
    false,
    1h,
    8h
);


-- ============================================================================
-- TEST 5 — Étendue minimale uniquement
-- Résultat attendu : étendue de 7h30m
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h,
    "DURATION_RANGE",
    false,
    1h,
    NONE
);


-- ============================================================================
-- TEST 6 — Étendue maximale uniquement
-- Résultat attendu : étendue de 7h30m
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h,
    "DURATION_RANGE",
    false,
    NONE,
    24h
);


-- ============================================================================
-- TEST 7 — Plage exacte autorisée
-- Résultat attendu :
-- {
--     min_duration: 1h,
--     max_duration: 1h,
--     span: 0ns
-- }
-- ============================================================================

RETURN fn::validation_duration_range(
    1h,
    1h,
    "APPOINTMENT_DURATION_RANGE",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 8 — Plage exacte autorisée avec étendue minimale nulle
-- Résultat attendu : étendue de 0ns
-- ============================================================================

RETURN fn::validation_duration_range(
    1h,
    1h,
    "APPOINTMENT_DURATION_RANGE",
    true,
    0ns,
    1h
);


-- ============================================================================
-- TEST 9 — Étendue exacte d'une heure
-- Résultat attendu : étendue de 1h
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    1h30m,
    "DURATION_RANGE",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 10 — Borne minimale nulle
-- Résultat attendu : étendue de 30m
-- ============================================================================

RETURN fn::validation_duration_range(
    0ns,
    30m,
    "TIMEOUT_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 11 — Deux bornes nulles avec plage exacte autorisée
-- Résultat attendu : étendue de 0ns
-- ============================================================================

RETURN fn::validation_duration_range(
    0ns,
    0ns,
    "ZERO_DURATION_RANGE",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 12 — Durées composées
-- Résultat attendu : étendue de 1d11h30m
-- ============================================================================

RETURN fn::validation_duration_range(
    12h30m,
    2d,
    "RETENTION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 13 — Durées équivalentes avec unités différentes
-- Résultat attendu : étendue de 0ns
-- ============================================================================

RETURN fn::validation_duration_range(
    60m,
    1h,
    "DURATION_RANGE",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 14 — Conversion explicite des deux chaînes
-- Résultat attendu : étendue de 7h30m
-- ============================================================================

LET $min_duration = type::duration(
    "30m"
);

LET $max_duration = type::duration(
    "8h"
);

RETURN fn::validation_duration_range(
    $min_duration,
    $max_duration,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Borne minimale absente
-- Erreur attendue : DURATION_RANGE_MIN_REQUIRED
-- ============================================================================

RETURN fn::validation_duration_range(
    NONE,
    8h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Borne minimale NULL
-- Erreur attendue : DURATION_RANGE_MIN_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_duration_range(
    NULL,
    8h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Borne minimale sous forme de chaîne
-- Erreur attendue : DURATION_RANGE_MIN_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration_range(
    "30m",
    8h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Borne minimale sous forme d'entier
-- Erreur attendue : DURATION_RANGE_MIN_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration_range(
    30,
    8h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Borne minimale sous forme de float
-- Erreur attendue : DURATION_RANGE_MIN_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration_range(
    30f,
    8h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 20 — Borne minimale sous forme de datetime
-- Erreur attendue : DURATION_RANGE_MIN_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration_range(
    d"2026-08-03T10:00:00Z",
    8h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 21 — Borne maximale absente
-- Erreur attendue : DURATION_RANGE_MAX_REQUIRED
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    NONE,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 22 — Borne maximale NULL
-- Erreur attendue : DURATION_RANGE_MAX_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    NULL,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 23 — Borne maximale sous forme de chaîne
-- Erreur attendue : DURATION_RANGE_MAX_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    "8h",
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 24 — Borne maximale sous forme d'entier
-- Erreur attendue : DURATION_RANGE_MAX_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 25 — Borne maximale sous forme de booléen
-- Erreur attendue : DURATION_RANGE_MAX_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    true,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 26 — Bornes inversées
-- Erreur attendue : DURATION_RANGE_INVALID_ORDER
-- ============================================================================

RETURN fn::validation_duration_range(
    8h,
    30m,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 27 — Bornes inversées d'une nanoseconde
-- Erreur attendue : DURATION_RANGE_INVALID_ORDER
-- ============================================================================

RETURN fn::validation_duration_range(
    1s,
    999ms999us999ns,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 28 — Plage exacte interdite
-- Erreur attendue : DURATION_RANGE_EXACT_RANGE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_duration_range(
    1h,
    1h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 29 — Durées équivalentes avec plage exacte interdite
-- Erreur attendue : DURATION_RANGE_EXACT_RANGE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_duration_range(
    60m,
    1h,
    "DURATION_RANGE",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 30 — Plage exacte autorisée mais étendue minimale positive
-- Erreur attendue : DURATION_RANGE_SPAN_TOO_SMALL
-- ============================================================================

RETURN fn::validation_duration_range(
    1h,
    1h,
    "DURATION_RANGE",
    true,
    1ns,
    NONE
);


-- ============================================================================
-- TEST 31 — Étendue inférieure à la limite minimale
-- Erreur attendue : DURATION_RANGE_SPAN_TOO_SMALL
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    1h29m59s,
    "DURATION_RANGE",
    false,
    1h,
    NONE
);


-- ============================================================================
-- TEST 32 — Étendue inférieure au minimum d'une nanoseconde
-- Erreur attendue : DURATION_RANGE_SPAN_TOO_SMALL
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    1h29m59s999ms999us999ns,
    "DURATION_RANGE",
    false,
    1h,
    NONE
);


-- ============================================================================
-- TEST 33 — Étendue supérieure à la limite maximale
-- Erreur attendue : DURATION_RANGE_SPAN_TOO_LARGE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h30m1s,
    "DURATION_RANGE",
    false,
    NONE,
    8h
);


-- ============================================================================
-- TEST 34 — Étendue supérieure au maximum d'une nanoseconde
-- Erreur attendue : DURATION_RANGE_SPAN_TOO_LARGE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h30m1ns,
    "DURATION_RANGE",
    false,
    NONE,
    8h
);


-- ============================================================================
-- TEST 35 — Étendue exacte non atteinte
-- Erreur attendue : DURATION_RANGE_SPAN_TOO_SMALL
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    1h29m59s,
    "DURATION_RANGE",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 36 — Étendue exacte dépassée
-- Erreur attendue : DURATION_RANGE_SPAN_TOO_LARGE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    1h30m1s,
    "DURATION_RANGE",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 37 — Limites d'étendue incohérentes
-- Erreur attendue : VALIDATION_INVALID_DURATION_SPAN_RANGE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h,
    "DURATION_RANGE",
    false,
    8h,
    1h
);


-- ============================================================================
-- TEST 38 — Configuration impossible avec plage exacte interdite
-- Erreur attendue : VALIDATION_IMPOSSIBLE_DURATION_RANGE
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    1h,
    "DURATION_RANGE",
    false,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 39 — Étendue maximale nulle avec plage exacte autorisée
-- Résultat attendu : étendue de 0ns
-- ============================================================================

RETURN fn::validation_duration_range(
    1h,
    1h,
    "DURATION_RANGE",
    true,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 40 — Étendue minimale et maximale nulles
-- Résultat attendu : étendue de 0ns
-- ============================================================================

RETURN fn::validation_duration_range(
    1h,
    1h,
    "DURATION_RANGE",
    true,
    0ns,
    0ns
);


-- ============================================================================
-- TEST 41 — Extraction de la durée minimale
-- Résultat attendu : 30m
-- ============================================================================

LET $range = fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);

RETURN $range.min_duration;


-- ============================================================================
-- TEST 42 — Extraction de la durée maximale
-- Résultat attendu : 8h
-- ============================================================================

LET $range = fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);

RETURN $range.max_duration;


-- ============================================================================
-- TEST 43 — Extraction de l'étendue
-- Résultat attendu : 7h30m
-- ============================================================================

LET $range = fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);

RETURN $range.span;


-- ============================================================================
-- TEST 44 — Conversion de l'étendue en minutes
-- Résultat attendu : 450
-- ============================================================================

LET $range = fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);

RETURN duration::mins(
    $range.span
);


-- ============================================================================
-- TEST 45 — Utilisation des bornes avec validation_duration
-- Résultat attendu : 2h
-- ============================================================================

LET $range = fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);

RETURN fn::validation_duration(
    2h,
    "BOOKING_DURATION",
    $range.min_duration,
    $range.max_duration
);


-- ============================================================================
-- TEST 46 — Durée inférieure aux bornes validées
-- Erreur attendue : BOOKING_DURATION_TOO_SHORT
-- ============================================================================

LET $range = fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);

RETURN fn::validation_duration(
    29m,
    "BOOKING_DURATION",
    $range.min_duration,
    $range.max_duration
);


-- ============================================================================
-- TEST 47 — Durée supérieure aux bornes validées
-- Erreur attendue : BOOKING_DURATION_TOO_LONG
-- ============================================================================

LET $range = fn::validation_duration_range(
    30m,
    8h,
    "BOOKING_DURATION_RANGE",
    false,
    NONE,
    NONE
);

RETURN fn::validation_duration(
    8h1s,
    "BOOKING_DURATION",
    $range.min_duration,
    $range.max_duration
);


-- ============================================================================
-- TEST 48 — Utilisation de duration::max
-- Résultat attendu : plage valide
-- ============================================================================

RETURN fn::validation_duration_range(
    0ns,
    duration::max,
    "GLOBAL_DURATION_RANGE",
    false,
    NONE,
    duration::max
);


-- ============================================================================
-- TEST 49 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_duration_range(
    30m,
    8h,
    "     ",
    false,
    NONE,
    NONE
);