-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/date_range.test.surql
-- Fonction     : fn::validation_date_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Plage valide
-- Résultat attendu : days = 9
-- ============================================================================
RETURN fn::validation_date_range(
    d"2026-08-01T00:00:00Z",
    d"2026-08-10T00:00:00Z",
    "DATE_RANGE",
    false,
    NONE,
    NONE
);

-- ============================================================================
-- TEST 2 — Même jour autorisé
-- Résultat attendu : days = 0
-- ============================================================================
RETURN fn::validation_date_range(
    d"2026-08-01T00:00:00Z",
    d"2026-08-01T00:00:00Z",
    "DATE_RANGE",
    true,
    0,
    0
);

-- ============================================================================
-- TEST 3 — Même jour interdit
-- Erreur attendue : DATE_RANGE_SAME_DAY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_date_range(
    d"2026-08-01T00:00:00Z",
    d"2026-08-01T00:00:00Z",
    "DATE_RANGE",
    false,
    NONE,
    NONE
);

-- ============================================================================
-- TEST 4 — Heure cachée dans la date de début
-- Erreur attendue : DATE_RANGE_START_INVALID_DATE
-- ============================================================================
RETURN fn::validation_date_range(
    d"2026-08-01T10:00:00Z",
    d"2026-08-10T00:00:00Z",
    "DATE_RANGE",
    false,
    NONE,
    NONE
);

-- ============================================================================
-- TEST 5 — Plage trop longue
-- Erreur attendue : DATE_RANGE_TOO_LONG
-- ============================================================================
RETURN fn::validation_date_range(
    d"2026-08-01T00:00:00Z",
    d"2026-08-20T00:00:00Z",
    "DATE_RANGE",
    false,
    NONE,
    10
);
