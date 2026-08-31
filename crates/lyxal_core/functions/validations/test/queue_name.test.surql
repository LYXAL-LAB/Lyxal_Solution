-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/queue_name.test.surql
-- Fonction     : fn::validation_queue_name
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — File valide
-- Résultat attendu : "email-high-priority"
-- ============================================================================
RETURN fn::validation_queue_name(
    "Email-High-Priority",
    "QUEUE_NAME",
    3,
    100
);

-- ============================================================================
-- TEST 2 — Tiret bas interdit
-- Erreur attendue : QUEUE_NAME_INVALID_QUEUE_NAME
-- ============================================================================
RETURN fn::validation_queue_name(
    "email_high_priority",
    "QUEUE_NAME",
    3,
    100
);
