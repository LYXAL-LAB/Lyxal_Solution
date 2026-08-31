-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/future_datetime.test.surql
-- Fonction     : fn::validation_future_datetime
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
--
-- Les tests principaux utilisent une référence explicite afin d'être
-- déterministes et reproductibles.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Datetime strictement futur
-- Résultat attendu : d"2026-08-03T12:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Datetime futur avec avance minimale et maximale
-- Résultat attendu : d"2026-08-03T12:00:00Z"
-- Note : avance de 2h
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    24h
);


-- ============================================================================
-- TEST 3 — Avance égale au minimum
-- Résultat attendu : d"2026-08-03T10:30:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:30:00Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    24h
);


-- ============================================================================
-- TEST 4 — Avance égale au maximum
-- Résultat attendu : d"2026-08-04T10:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-04T10:00:00Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    24h
);


-- ============================================================================
-- TEST 5 — Avance minimale uniquement
-- Résultat attendu : d"2026-08-03T12:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    NONE
);


-- ============================================================================
-- TEST 6 — Avance maximale uniquement
-- Résultat attendu : d"2026-08-03T12:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    24h
);


-- ============================================================================
-- TEST 7 — Égalité autorisée
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 8 — Égalité autorisée avec minimum égal à zéro
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    0ns,
    1h
);


-- ============================================================================
-- TEST 9 — Avance exacte d'une heure
-- Résultat attendu : d"2026-08-03T11:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T11:00:00Z",
    "EXECUTE_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 10 — Avance d'une nanoseconde
-- Résultat attendu : datetime situé une nanoseconde après la référence
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00.000000001Z",
    "EXECUTE_AT",
    d"2026-08-03T10:00:00.000000000Z",
    false,
    1ns,
    NONE
);


-- ============================================================================
-- TEST 11 — Valeur convertie depuis une chaîne
-- Résultat attendu : d"2026-08-03T12:00:00Z"
-- ============================================================================

LET $scheduled_at = type::datetime(
    "2026-08-03T12:00:00Z"
);

RETURN fn::validation_future_datetime(
    $scheduled_at,
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 12 — Référence et valeur exprimées avec des fuseaux différents
-- Résultat attendu : d"2026-08-03T13:00:00+02:00"
-- Note :
-- référence 10:00 UTC
-- valeur 13:00 +02:00 = 11:00 UTC
-- avance réelle de 1h
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T13:00:00+02:00",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 13 — Valeur absente
-- Erreur attendue : SCHEDULED_AT_REQUIRED
-- ============================================================================

RETURN fn::validation_future_datetime(
    NONE,
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 14 — Valeur NULL
-- Erreur attendue : SCHEDULED_AT_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_future_datetime(
    NULL,
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Chaîne datetime non convertie
-- Erreur attendue : SCHEDULED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_future_datetime(
    "2026-08-03T12:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Entier à la place d'un datetime
-- Erreur attendue : SCHEDULED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_future_datetime(
    1785758400,
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Float à la place d'un datetime
-- Erreur attendue : SCHEDULED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_future_datetime(
    1785758400f,
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Durée à la place d'un datetime
-- Erreur attendue : SCHEDULED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_future_datetime(
    2h,
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Booléen à la place d'un datetime
-- Erreur attendue : SCHEDULED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_future_datetime(
    true,
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 20 — Objet à la place d'un datetime
-- Erreur attendue : SCHEDULED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_future_datetime(
    {
        value: d"2026-08-03T12:00:00Z"
    },
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 21 — Datetime antérieur à la référence
-- Erreur attendue : SCHEDULED_AT_NOT_IN_FUTURE
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T09:59:59Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 22 — Datetime égal avec égalité interdite
-- Erreur attendue : SCHEDULED_AT_NOT_IN_FUTURE
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 23 — Deux représentations du même instant avec égalité interdite
-- Erreur attendue : SCHEDULED_AT_NOT_IN_FUTURE
-- Note :
-- 12:00 +02:00 correspond à 10:00 UTC
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T12:00:00+02:00",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 24 — Égalité autorisée mais avance minimale positive
-- Erreur attendue : SCHEDULED_AT_TOO_SOON
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    1ns,
    NONE
);


-- ============================================================================
-- TEST 25 — Avance inférieure au minimum
-- Erreur attendue : START_AT_TOO_SOON
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:29:59Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    NONE
);


-- ============================================================================
-- TEST 26 — Avance inférieure au minimum d'une nanoseconde
-- Erreur attendue : START_AT_TOO_SOON
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:29:59.999999999Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    NONE
);


-- ============================================================================
-- TEST 27 — Avance supérieure au maximum
-- Erreur attendue : START_AT_TOO_FAR
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-04T10:00:01Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    24h
);


-- ============================================================================
-- TEST 28 — Avance supérieure au maximum d'une nanoseconde
-- Erreur attendue : START_AT_TOO_FAR
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-04T10:00:00.000000001Z",
    "START_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    24h
);


-- ============================================================================
-- TEST 29 — Avance exacte non atteinte
-- Erreur attendue : EXECUTE_AT_TOO_SOON
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:59:59Z",
    "EXECUTE_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 30 — Avance exacte dépassée
-- Erreur attendue : EXECUTE_AT_TOO_FAR
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T11:00:01Z",
    "EXECUTE_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 31 — Plage d'avance incohérente
-- Erreur attendue : VALIDATION_INVALID_FUTURE_RANGE
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    24h,
    1h
);


-- ============================================================================
-- TEST 32 — Configuration impossible avec égalité interdite
-- Erreur attendue : VALIDATION_IMPOSSIBLE_FUTURE_RANGE
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 33 — Maximum nul avec égalité autorisée
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 34 — Minimum et maximum nuls avec égalité autorisée
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T10:00:00Z",
    "SCHEDULED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    0ns,
    0ns
);


-- ============================================================================
-- TEST 35 — Référence automatique avec une valeur future
-- Résultat attendu : datetime environ une heure après l'exécution
-- ============================================================================

LET $reference_time = time::now();
LET $scheduled_at = $reference_time + 1h;

RETURN fn::validation_future_datetime(
    $scheduled_at,
    "SCHEDULED_AT",
    $reference_time,
    false,
    30m,
    2h
);


-- ============================================================================
-- TEST 36 — Utilisation directe de time::now()
-- Résultat attendu : datetime environ une heure dans le futur
-- Note : une marge minimale de 30m évite les effets du temps d'exécution
-- ============================================================================

LET $scheduled_at = time::now() + 1h;

RETURN fn::validation_future_datetime(
    $scheduled_at,
    "SCHEDULED_AT",
    NONE,
    false,
    30m,
    2h
);


-- ============================================================================
-- TEST 37 — Valeur actuelle avec égalité interdite
-- Erreur attendue : SCHEDULED_AT_NOT_IN_FUTURE
-- Note : la référence interne sera égale ou légèrement postérieure
-- ============================================================================

LET $scheduled_at = time::now();

RETURN fn::validation_future_datetime(
    $scheduled_at,
    "SCHEDULED_AT",
    NONE,
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 38 — Validation puis calcul de l'avance
-- Résultat attendu : 2h
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $scheduled_at = fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "SCHEDULED_AT",
    $reference_time,
    false,
    NONE,
    NONE
);

RETURN $scheduled_at - $reference_time;


-- ============================================================================
-- TEST 39 — Validation puis conversion de l'avance en minutes
-- Résultat attendu : 150
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $scheduled_at = fn::validation_future_datetime(
    d"2026-08-03T12:30:00Z",
    "SCHEDULED_AT",
    $reference_time,
    false,
    NONE,
    NONE
);

RETURN duration::mins(
    $scheduled_at - $reference_time
);


-- ============================================================================
-- TEST 40 — Validation de deux datetimes avec la même référence
-- Résultat attendu : objet contenant deux datetimes futurs
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $start_at = fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "START_AT",
    $reference_time,
    false,
    30m,
    24h
);

LET $end_at = fn::validation_future_datetime(
    d"2026-08-03T14:00:00Z",
    "END_AT",
    $reference_time,
    false,
    30m,
    24h
);

RETURN {
    start_at: $start_at,
    end_at: $end_at
};


-- ============================================================================
-- TEST 41 — Validation future puis validation de plage
-- Résultat attendu : plage d'une durée de 2h
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $start_at = fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "START_AT",
    $reference_time,
    false,
    30m,
    24h
);

LET $end_at = fn::validation_future_datetime(
    d"2026-08-03T14:00:00Z",
    "END_AT",
    $reference_time,
    false,
    30m,
    24h
);

RETURN fn::validation_time_range(
    $start_at,
    $end_at,
    "BOOKING_RANGE",
    false,
    30m,
    8h
);


-- ============================================================================
-- TEST 42 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_future_datetime(
    d"2026-08-03T12:00:00Z",
    "     ",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);