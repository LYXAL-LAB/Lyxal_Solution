-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/execution_priority.test.surql
-- Fonction     : fn::validation_execution_priority
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Priorité valide
-- Résultat attendu : 50
-- ============================================================================
RETURN fn::validation_execution_priority(
    50,
    "PRIORITY",
    0,
    100
);

-- ============================================================================
-- TEST 2 — Priorité trop élevée
-- Erreur attendue : PRIORITY_PRIORITY_TOO_HIGH
-- ============================================================================
RETURN fn::validation_execution_priority(
    101,
    "PRIORITY",
    0,
    100
);

-- ============================================================================
-- TEST 3 — Decimal refusé
-- Erreur attendue : PRIORITY_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_execution_priority(
    50dec,
    "PRIORITY",
    0,
    100
);
