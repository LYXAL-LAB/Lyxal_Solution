-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/workflow_delay.test.surql
-- Fonction     : fn::validation_workflow_delay
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Délai valide
-- Résultat attendu : 30s
-- ============================================================================
RETURN fn::validation_workflow_delay(
    30s,
    "DELAY",
    0s,
    24h,
    true
);

-- ============================================================================
-- TEST 2 — Zéro interdit
-- Erreur attendue : DELAY_ZERO_DELAY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_workflow_delay(
    0s,
    "DELAY",
    0s,
    24h,
    false
);

-- ============================================================================
-- TEST 3 — Délai trop long
-- Erreur attendue : DELAY_DELAY_TOO_LONG
-- ============================================================================
RETURN fn::validation_workflow_delay(
    48h,
    "DELAY",
    0s,
    24h,
    true
);
