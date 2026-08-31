-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/business_day.test.surql
-- Fonction     : fn::validation_business_day
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Lundi ouvré
-- Résultat attendu : d"2026-08-03T00:00:00Z"
-- ============================================================================
RETURN fn::validation_business_day(
    d"2026-08-03T00:00:00Z",
    "WORK_DATE",
    NONE
);

-- ============================================================================
-- TEST 2 — Samedi refusé
-- Erreur attendue : WORK_DATE_WEEKEND_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_business_day(
    d"2026-08-01T00:00:00Z",
    "WORK_DATE",
    NONE
);

-- ============================================================================
-- TEST 3 — Dimanche refusé
-- Erreur attendue : WORK_DATE_WEEKEND_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_business_day(
    d"2026-08-02T00:00:00Z",
    "WORK_DATE",
    NONE
);

-- ============================================================================
-- TEST 4 — Jour férié fourni
-- Erreur attendue : WORK_DATE_HOLIDAY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_business_day(
    d"2026-08-15T00:00:00Z",
    "WORK_DATE",
    [d"2026-08-15T00:00:00Z"]
);

-- ============================================================================
-- TEST 5 — Date avec heure
-- Erreur attendue : WORK_DATE_INVALID_DATE
-- ============================================================================
RETURN fn::validation_business_day(
    d"2026-08-03T10:00:00Z",
    "WORK_DATE",
    NONE
);
