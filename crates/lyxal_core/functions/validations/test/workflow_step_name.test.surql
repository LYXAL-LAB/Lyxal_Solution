-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/workflow_step_name.test.surql
-- Fonction     : fn::validation_workflow_step_name
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Étape valide
-- Résultat attendu : "validate_customer"
-- ============================================================================
RETURN fn::validation_workflow_step_name(
    "Validate_Customer",
    "STEP_NAME",
    3,
    100
);

-- ============================================================================
-- TEST 2 — Chiffre initial interdit
-- Erreur attendue : STEP_NAME_INVALID_STEP_NAME
-- ============================================================================
RETURN fn::validation_workflow_step_name(
    "1_validate_customer",
    "STEP_NAME",
    3,
    100
);
