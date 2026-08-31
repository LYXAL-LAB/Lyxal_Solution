-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/datetime_string.test.surql
-- Fonction     : fn::validation_datetime_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — RFC 3339 valide
-- Résultat attendu : "2026-08-03T10:00:00Z"
-- ============================================================================
RETURN fn::validation_datetime_string(
    "2026-08-03T10:00:00Z", "DATETIME", NONE
);

-- ============================================================================
-- TEST 2 — Format personnalisé valide
-- Résultat attendu : "03/08/2026 10:30"
-- ============================================================================
RETURN fn::validation_datetime_string(
    "03/08/2026 10:30", "DATETIME", "%d/%m/%Y %H:%M"
);

-- ============================================================================
-- TEST 3 — Format personnalisé non respecté
-- Erreur attendue : DATETIME_INVALID_DATETIME_STRING
-- ============================================================================
RETURN fn::validation_datetime_string(
    "2026-08-03 10:30", "DATETIME", "%d/%m/%Y %H:%M"
);

-- ============================================================================
-- TEST 4 — Format vide
-- Erreur attendue : VALIDATION_INVALID_DATETIME_FORMAT
-- ============================================================================
RETURN fn::validation_datetime_string(
    "2026-08-03", "DATETIME", "   "
);
