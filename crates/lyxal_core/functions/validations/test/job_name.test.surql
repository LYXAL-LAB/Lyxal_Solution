-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/job_name.test.surql
-- Fonction     : fn::validation_job_name
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nom de job valide
-- Résultat attendu : "send_daily_report"
-- ============================================================================
RETURN fn::validation_job_name(
    "Send_Daily_Report",
    "JOB_NAME",
    3,
    100
);

-- ============================================================================
-- TEST 2 — Tiret interdit
-- Erreur attendue : JOB_NAME_INVALID_JOB_NAME
-- ============================================================================
RETURN fn::validation_job_name(
    "send-daily-report",
    "JOB_NAME",
    3,
    100
);
