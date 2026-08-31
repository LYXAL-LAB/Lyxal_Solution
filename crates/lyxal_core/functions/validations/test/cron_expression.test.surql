-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/cron_expression.test.surql
-- Fonction     : fn::validation_cron_expression
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Cron standard
-- Résultat attendu : "0 8 * * 1-5"
-- ============================================================================
RETURN fn::validation_cron_expression(
    "0 8 * * 1-5",
    "CRON",
    false,
    false
);

-- ============================================================================
-- TEST 2 — Cron avec secondes
-- Résultat attendu : "0 0 8 * * 1-5"
-- ============================================================================
RETURN fn::validation_cron_expression(
    "0 0 8 * * 1-5",
    "CRON",
    true,
    false
);

-- ============================================================================
-- TEST 3 — Macro autorisée
-- Résultat attendu : "@daily"
-- ============================================================================
RETURN fn::validation_cron_expression(
    "@daily",
    "CRON",
    false,
    true
);

-- ============================================================================
-- TEST 4 — Nombre de champs invalide
-- Erreur attendue : CRON_INVALID_CRON_FIELD_COUNT
-- ============================================================================
RETURN fn::validation_cron_expression(
    "0 8 * *",
    "CRON",
    false,
    false
);
