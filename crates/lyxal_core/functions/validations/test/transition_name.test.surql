-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/transition_name.test.surql
-- Fonction     : fn::validation_transition_name
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Transition valide
-- Résultat attendu : "pending_to_active"
-- ============================================================================
RETURN fn::validation_transition_name(
    "Pending_To_Active",
    "TRANSITION_NAME",
    3,
    100
);

-- ============================================================================
-- TEST 2 — Point interdit
-- Erreur attendue : TRANSITION_NAME_INVALID_TRANSITION_NAME
-- ============================================================================
RETURN fn::validation_transition_name(
    "pending.to.active",
    "TRANSITION_NAME",
    3,
    100
);
