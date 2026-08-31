-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/past_datetime.test.surql
-- Fonction     : fn::validation_past_datetime
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
-- TEST 1 — Datetime strictement passé
-- Résultat attendu : d"2026-08-03T08:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Datetime passé avec ancienneté minimale et maximale
-- Résultat attendu : d"2026-08-03T08:00:00Z"
-- Note : ancienneté de 2h
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    24h
);


-- ============================================================================
-- TEST 3 — Ancienneté égale au minimum
-- Résultat attendu : d"2026-08-03T09:30:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T09:30:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    24h
);


-- ============================================================================
-- TEST 4 — Ancienneté égale au maximum
-- Résultat attendu : d"2026-08-02T10:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-02T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    24h
);


-- ============================================================================
-- TEST 5 — Ancienneté minimale uniquement
-- Résultat attendu : d"2026-08-03T08:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    NONE
);


-- ============================================================================
-- TEST 6 — Ancienneté maximale uniquement
-- Résultat attendu : d"2026-08-03T08:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    24h
);


-- ============================================================================
-- TEST 7 — Égalité autorisée
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 8 — Égalité autorisée avec ancienneté minimale égale à zéro
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    0ns,
    1h
);


-- ============================================================================
-- TEST 9 — Ancienneté exacte d'une heure
-- Résultat attendu : d"2026-08-03T09:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T09:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 10 — Valeur située une nanoseconde dans le passé
-- Résultat attendu : datetime situé une nanoseconde avant la référence
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T09:59:59.999999999Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00.000000000Z",
    false,
    1ns,
    NONE
);


-- ============================================================================
-- TEST 11 — Valeur convertie depuis une chaîne
-- Résultat attendu : d"2026-08-03T08:00:00Z"
-- ============================================================================

LET $executed_at = type::datetime(
    "2026-08-03T08:00:00Z"
);

RETURN fn::validation_past_datetime(
    $executed_at,
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 12 — Valeur et référence exprimées avec des fuseaux différents
-- Résultat attendu : datetime correspondant à 09:00 UTC
-- Note :
-- valeur 11:00 +02:00 = 09:00 UTC
-- référence 10:00 UTC
-- ancienneté réelle de 1h
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T11:00:00+02:00",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 13 — Valeur absente
-- Erreur attendue : EXECUTED_AT_REQUIRED
-- ============================================================================

RETURN fn::validation_past_datetime(
    NONE,
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 14 — Valeur NULL
-- Erreur attendue : EXECUTED_AT_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_past_datetime(
    NULL,
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Chaîne datetime non convertie
-- Erreur attendue : EXECUTED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_past_datetime(
    "2026-08-03T08:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Entier à la place d'un datetime
-- Erreur attendue : EXECUTED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_past_datetime(
    1785744000,
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Float à la place d'un datetime
-- Erreur attendue : EXECUTED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_past_datetime(
    1785744000f,
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Durée à la place d'un datetime
-- Erreur attendue : EXECUTED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_past_datetime(
    2h,
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Booléen à la place d'un datetime
-- Erreur attendue : EXECUTED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_past_datetime(
    true,
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 20 — Objet à la place d'un datetime
-- Erreur attendue : EXECUTED_AT_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_past_datetime(
    {
        value: d"2026-08-03T08:00:00Z"
    },
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 21 — Datetime postérieur à la référence
-- Erreur attendue : EXECUTED_AT_NOT_IN_PAST
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:01Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 22 — Datetime égal avec égalité interdite
-- Erreur attendue : EXECUTED_AT_NOT_IN_PAST
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 23 — Deux représentations du même instant avec égalité interdite
-- Erreur attendue : EXECUTED_AT_NOT_IN_PAST
-- Note :
-- 12:00 +02:00 correspond à 10:00 UTC
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T12:00:00+02:00",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 24 — Égalité autorisée mais ancienneté minimale positive
-- Erreur attendue : EXECUTED_AT_TOO_RECENT
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    1ns,
    NONE
);


-- ============================================================================
-- TEST 25 — Ancienneté inférieure au minimum
-- Erreur attendue : EXECUTED_AT_TOO_RECENT
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T09:30:01Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    30m,
    NONE
);


-- ============================================================================
-- TEST 26 — Ancienneté inférieure au minimum d'une nanoseconde
-- Erreur attendue : EXECUTED_AT_TOO_RECENT
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T09:30:00.000000001Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00.000000000Z",
    false,
    30m,
    NONE
);


-- ============================================================================
-- TEST 27 — Ancienneté supérieure au maximum
-- Erreur attendue : EXECUTED_AT_TOO_OLD
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-02T09:59:59Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    24h
);


-- ============================================================================
-- TEST 28 — Ancienneté supérieure au maximum d'une nanoseconde
-- Erreur attendue : EXECUTED_AT_TOO_OLD
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-02T09:59:59.999999999Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00.000000000Z",
    false,
    NONE,
    24h
);


-- ============================================================================
-- TEST 29 — Ancienneté exacte non atteinte
-- Erreur attendue : EXECUTED_AT_TOO_RECENT
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T09:00:01Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 30 — Ancienneté exacte dépassée
-- Erreur attendue : EXECUTED_AT_TOO_OLD
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:59:59Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    1h,
    1h
);


-- ============================================================================
-- TEST 31 — Plage d'ancienneté incohérente
-- Erreur attendue : VALIDATION_INVALID_PAST_RANGE
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    24h,
    1h
);


-- ============================================================================
-- TEST 32 — Configuration impossible avec égalité interdite
-- Erreur attendue : VALIDATION_IMPOSSIBLE_PAST_RANGE
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 33 — Maximum nul avec égalité autorisée
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    NONE,
    0ns
);


-- ============================================================================
-- TEST 34 — Minimum et maximum nuls avec égalité autorisée
-- Résultat attendu : d"2026-08-03T10:00:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T10:00:00Z",
    "EXECUTED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    0ns,
    0ns
);


-- ============================================================================
-- TEST 35 — Référence dynamique avec une valeur passée
-- Résultat attendu : datetime environ une heure avant la référence
-- ============================================================================

LET $reference_time = time::now();
LET $executed_at = $reference_time - 1h;

RETURN fn::validation_past_datetime(
    $executed_at,
    "EXECUTED_AT",
    $reference_time,
    false,
    30m,
    2h
);


-- ============================================================================
-- TEST 36 — Utilisation directe de time::now()
-- Résultat attendu : datetime environ une heure dans le passé
-- ============================================================================

LET $executed_at = time::now() - 1h;

RETURN fn::validation_past_datetime(
    $executed_at,
    "EXECUTED_AT",
    NONE,
    false,
    30m,
    2h
);


-- ============================================================================
-- TEST 37 — Valeur actuelle avec égalité interdite
-- Résultat attendu :
-- généralement le datetime est accepté comme légèrement passé, car la
-- référence interne est évaluée après la création de $executed_at.
--
-- Note :
-- ce test n'est pas déterministe à la nanoseconde et ne doit pas servir de
-- test unitaire strict.
-- ============================================================================

LET $executed_at = time::now();

RETURN fn::validation_past_datetime(
    $executed_at,
    "EXECUTED_AT",
    NONE,
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 38 — Validation puis calcul de l'ancienneté
-- Résultat attendu : 2h
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $executed_at = fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "EXECUTED_AT",
    $reference_time,
    false,
    NONE,
    NONE
);

RETURN $reference_time - $executed_at;


-- ============================================================================
-- TEST 39 — Conversion de l'ancienneté en minutes
-- Résultat attendu : 150
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $executed_at = fn::validation_past_datetime(
    d"2026-08-03T07:30:00Z",
    "EXECUTED_AT",
    $reference_time,
    false,
    NONE,
    NONE
);

RETURN duration::mins(
    $reference_time - $executed_at
);


-- ============================================================================
-- TEST 40 — Validation de deux datetimes avec la même référence
-- Résultat attendu : objet contenant deux datetimes passés
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $started_at = fn::validation_past_datetime(
    d"2026-08-03T06:00:00Z",
    "STARTED_AT",
    $reference_time,
    false,
    NONE,
    24h
);

LET $completed_at = fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "COMPLETED_AT",
    $reference_time,
    false,
    NONE,
    24h
);

RETURN {
    started_at: $started_at,
    completed_at: $completed_at
};


-- ============================================================================
-- TEST 41 — Validation passée puis validation de la plage
-- Résultat attendu : plage d'une durée de 2h
-- ============================================================================

LET $reference_time = d"2026-08-03T10:00:00Z";

LET $started_at = fn::validation_past_datetime(
    d"2026-08-03T06:00:00Z",
    "STARTED_AT",
    $reference_time,
    false,
    NONE,
    24h
);

LET $completed_at = fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "COMPLETED_AT",
    $reference_time,
    false,
    NONE,
    24h
);

RETURN fn::validation_time_range(
    $started_at,
    $completed_at,
    "EXECUTION_RANGE",
    false,
    1m,
    8h
);


-- ============================================================================
-- TEST 42 — Valeur passée trop ancienne pour la fenêtre autorisée
-- Erreur attendue : SYNCHRONIZED_AT_TOO_OLD
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "SYNCHRONIZED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    NONE,
    1h
);


-- ============================================================================
-- TEST 43 — Valeur récente dans la fenêtre autorisée
-- Résultat attendu : d"2026-08-03T09:30:00Z"
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T09:30:00Z",
    "SYNCHRONIZED_AT",
    d"2026-08-03T10:00:00Z",
    true,
    NONE,
    1h
);


-- ============================================================================
-- TEST 44 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_past_datetime(
    d"2026-08-03T08:00:00Z",
    "     ",
    d"2026-08-03T10:00:00Z",
    false,
    NONE,
    NONE
);