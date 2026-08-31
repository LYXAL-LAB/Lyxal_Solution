-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/time_of_day_range.test.surql
-- Fonction     : fn::validation_time_of_day_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Créneau de journée
-- Résultat attendu : duration_minutes = 480
-- ============================================================================
RETURN fn::validation_time_of_day_range(
    480, 960, "OPENING_RANGE", false, false
);

-- ============================================================================
-- TEST 2 — Créneau traversant minuit
-- Résultat attendu : duration_minutes = 240, overnight = true
-- ============================================================================
RETURN fn::validation_time_of_day_range(
    1320, 120, "SHIFT_RANGE", true, false
);

-- ============================================================================
-- TEST 3 — Passage de minuit interdit
-- Erreur attendue : SHIFT_RANGE_INVALID_ORDER
-- ============================================================================
RETURN fn::validation_time_of_day_range(
    1320, 120, "SHIFT_RANGE", false, false
);

-- ============================================================================
-- TEST 4 — Durée nulle interdite
-- Erreur attendue : RANGE_ZERO_DURATION_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_time_of_day_range(
    600, 600, "RANGE", true, false
);

-- ============================================================================
-- TEST 5 — Borne hors plage
-- Erreur attendue : RANGE_END_OUT_OF_RANGE
-- ============================================================================
RETURN fn::validation_time_of_day_range(
    600, 1440, "RANGE", true, false
);
