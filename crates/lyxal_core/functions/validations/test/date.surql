-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/date.test.surql
-- Fonction     : fn::validation_date
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
-- TEST 1 — Date civile valide sans limites
-- Résultat attendu : d"2026-08-03T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T00:00:00Z",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Date civile obtenue depuis une chaîne YYYY-MM-DD
-- Résultat attendu : d"2026-08-03T00:00:00Z"
-- ============================================================================

LET $converted_date = type::datetime(
    "2026-08-03"
);

RETURN fn::validation_date(
    $converted_date,
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 3 — Date comprise dans une plage
-- Résultat attendu : d"2026-08-15T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "WORKSITE_DATE",
    d"2026-08-01T00:00:00Z",
    d"2026-08-31T00:00:00Z"
);


-- ============================================================================
-- TEST 4 — Date égale à la limite minimale
-- Résultat attendu : d"2026-08-01T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-01T00:00:00Z",
    "START_DATE",
    d"2026-08-01T00:00:00Z",
    d"2026-08-31T00:00:00Z"
);


-- ============================================================================
-- TEST 5 — Date égale à la limite maximale
-- Résultat attendu : d"2026-08-31T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-31T00:00:00Z",
    "END_DATE",
    d"2026-08-01T00:00:00Z",
    d"2026-08-31T00:00:00Z"
);


-- ============================================================================
-- TEST 6 — Limite minimale uniquement
-- Résultat attendu : d"2026-08-15T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "START_DATE",
    d"2026-08-01T00:00:00Z",
    NONE
);


-- ============================================================================
-- TEST 7 — Limite maximale uniquement
-- Résultat attendu : d"2026-08-15T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "END_DATE",
    NONE,
    d"2026-08-31T00:00:00Z"
);


-- ============================================================================
-- TEST 8 — Date au début de l'époque Unix
-- Résultat attendu : d"1970-01-01T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"1970-01-01T00:00:00Z",
    "DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 9 — Date antérieure à l'époque Unix
-- Résultat attendu : d"1950-01-01T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"1950-01-01T00:00:00Z",
    "BIRTH_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 10 — Date bissextile valide
-- Résultat attendu : d"2024-02-29T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2024-02-29T00:00:00Z",
    "DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 11 — Premier jour de l'année
-- Résultat attendu : d"2026-01-01T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-01-01T00:00:00Z",
    "DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 12 — Dernier jour de l'année
-- Résultat attendu : d"2026-12-31T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-12-31T00:00:00Z",
    "DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 13 — Date actuelle normalisée au début du jour UTC
-- Résultat attendu : datetime du jour courant à minuit UTC
-- ============================================================================

LET $today = time::floor(
    time::now(),
    1d
);

RETURN fn::validation_date(
    $today,
    "TODAY",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 14 — Valeur absente
-- Erreur attendue : START_DATE_REQUIRED
-- ============================================================================

RETURN fn::validation_date(
    NONE,
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Valeur NULL
-- Erreur attendue : START_DATE_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_date(
    NULL,
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Chaîne YYYY-MM-DD non convertie
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    "2026-08-03",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Chaîne RFC 3339 non convertie
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    "2026-08-03T00:00:00Z",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Entier à la place d'une date
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    20260803,
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Float à la place d'une date
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    20260803f,
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 20 — Booléen à la place d'une date
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    true,
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 21 — Durée à la place d'une date
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    1d,
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 22 — Tableau à la place d'une date
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    [2026, 8, 3],
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 23 — Objet à la place d'une date
-- Erreur attendue : START_DATE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_date(
    {
        year: 2026,
        month: 8,
        day: 3
    },
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 24 — Datetime contenant une heure
-- Erreur attendue : START_DATE_INVALID_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T10:30:00Z",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 25 — Datetime contenant une seconde
-- Erreur attendue : START_DATE_INVALID_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T00:00:01Z",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 26 — Datetime contenant une milliseconde
-- Erreur attendue : START_DATE_INVALID_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T00:00:00.001Z",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 27 — Datetime situé une nanoseconde après minuit
-- Erreur attendue : START_DATE_INVALID_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T00:00:00.000000001Z",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 28 — Datetime juste avant le jour suivant
-- Erreur attendue : START_DATE_INVALID_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T23:59:59.999999999Z",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 29 — Datetime à minuit avec fuseau +02:00
-- Erreur attendue : START_DATE_INVALID_DATE
-- Note : la valeur est convertie en 2026-08-02T22:00:00Z
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T00:00:00+02:00",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 30 — Datetime à 02:00 avec fuseau +02:00
-- Résultat attendu : d"2026-08-03T00:00:00Z"
-- Note : après conversion UTC, la valeur correspond exactement à minuit UTC
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T02:00:00+02:00",
    "START_DATE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 31 — Date antérieure à la limite minimale
-- Erreur attendue : START_DATE_TOO_EARLY
-- ============================================================================

RETURN fn::validation_date(
    d"2026-07-31T00:00:00Z",
    "START_DATE",
    d"2026-08-01T00:00:00Z",
    NONE
);


-- ============================================================================
-- TEST 32 — Date postérieure à la limite maximale
-- Erreur attendue : END_DATE_TOO_LATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-09-01T00:00:00Z",
    "END_DATE",
    NONE,
    d"2026-08-31T00:00:00Z"
);


-- ============================================================================
-- TEST 33 — Limite minimale contenant une heure
-- Erreur attendue : VALIDATION_INVALID_MIN_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "START_DATE",
    d"2026-08-01T10:00:00Z",
    d"2026-08-31T00:00:00Z"
);


-- ============================================================================
-- TEST 34 — Limite maximale contenant une heure
-- Erreur attendue : VALIDATION_INVALID_MAX_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "END_DATE",
    d"2026-08-01T00:00:00Z",
    d"2026-08-31T23:59:59Z"
);


-- ============================================================================
-- TEST 35 — Limite minimale contenant une nanoseconde
-- Erreur attendue : VALIDATION_INVALID_MIN_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "START_DATE",
    d"2026-08-01T00:00:00.000000001Z",
    NONE
);


-- ============================================================================
-- TEST 36 — Limite maximale contenant une milliseconde
-- Erreur attendue : VALIDATION_INVALID_MAX_DATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "END_DATE",
    NONE,
    d"2026-08-31T00:00:00.001Z"
);


-- ============================================================================
-- TEST 37 — Plage de dates incohérente
-- Erreur attendue : VALIDATION_INVALID_DATE_RANGE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "START_DATE",
    d"2026-08-31T00:00:00Z",
    d"2026-08-01T00:00:00Z"
);


-- ============================================================================
-- TEST 38 — Minimum et maximum identiques
-- Résultat attendu : d"2026-08-15T00:00:00Z"
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-15T00:00:00Z",
    "DATE",
    d"2026-08-15T00:00:00Z",
    d"2026-08-15T00:00:00Z"
);


-- ============================================================================
-- TEST 39 — Valeur avant une plage exacte
-- Erreur attendue : DATE_TOO_EARLY
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-14T00:00:00Z",
    "DATE",
    d"2026-08-15T00:00:00Z",
    d"2026-08-15T00:00:00Z"
);


-- ============================================================================
-- TEST 40 — Valeur après une plage exacte
-- Erreur attendue : DATE_TOO_LATE
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-16T00:00:00Z",
    "DATE",
    d"2026-08-15T00:00:00Z",
    d"2026-08-15T00:00:00Z"
);


-- ============================================================================
-- TEST 41 — Date de naissance limitée au jour courant
-- Résultat attendu : d"1990-05-15T00:00:00Z"
-- ============================================================================

LET $today = time::floor(
    time::now(),
    1d
);

RETURN fn::validation_date(
    d"1990-05-15T00:00:00Z",
    "BIRTH_DATE",
    NONE,
    $today
);


-- ============================================================================
-- TEST 42 — Date future refusée comme date de naissance
-- Erreur attendue : BIRTH_DATE_TOO_LATE
-- ============================================================================

LET $today = time::floor(
    time::now(),
    1d
);

LET $tomorrow = $today + 1d;

RETURN fn::validation_date(
    $tomorrow,
    "BIRTH_DATE",
    NONE,
    $today
);


-- ============================================================================
-- TEST 43 — Formatage d'une date validée
-- Résultat attendu : "2026-08-03"
-- ============================================================================

LET $date = fn::validation_date(
    d"2026-08-03T00:00:00Z",
    "START_DATE",
    NONE,
    NONE
);

RETURN time::format(
    $date,
    "%Y-%m-%d"
);


-- ============================================================================
-- TEST 44 — Ajout d'un jour après validation
-- Résultat attendu : d"2026-08-04T00:00:00Z"
-- ============================================================================

LET $date = fn::validation_date(
    d"2026-08-03T00:00:00Z",
    "START_DATE",
    NONE,
    NONE
);

RETURN $date + 1d;


-- ============================================================================
-- TEST 45 — Différence entre deux dates validées
-- Résultat attendu : 9d
-- ============================================================================

LET $start_date = fn::validation_date(
    d"2026-08-01T00:00:00Z",
    "START_DATE",
    NONE,
    NONE
);

LET $end_date = fn::validation_date(
    d"2026-08-10T00:00:00Z",
    "END_DATE",
    NONE,
    NONE
);

RETURN $end_date - $start_date;


-- ============================================================================
-- TEST 46 — Comparaison de deux dates validées
-- Résultat attendu : true
-- ============================================================================

LET $start_date = fn::validation_date(
    d"2026-08-01T00:00:00Z",
    "START_DATE",
    NONE,
    NONE
);

LET $end_date = fn::validation_date(
    d"2026-08-10T00:00:00Z",
    "END_DATE",
    NONE,
    NONE
);

RETURN $start_date < $end_date;


-- ============================================================================
-- TEST 47 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_date(
    d"2026-08-03T00:00:00Z",
    "     ",
    NONE,
    NONE
);