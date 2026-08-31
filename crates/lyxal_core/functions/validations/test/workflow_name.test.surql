-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/workflow_name.test.surql
-- Fonction     : fn::validation_workflow_name
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Workflow valide
-- Résultat attendu : "customer_onboarding"
-- ============================================================================
RETURN fn::validation_workflow_name(
    "Customer_Onboarding",
    "WORKFLOW_NAME",
    3,
    100
);

-- ============================================================================
-- TEST 2 — Espace interdit
-- Erreur attendue : WORKFLOW_NAME_INVALID_WORKFLOW_NAME
-- ============================================================================
RETURN fn::validation_workflow_name(
    "customer onboarding",
    "WORKFLOW_NAME",
    3,
    100
);
