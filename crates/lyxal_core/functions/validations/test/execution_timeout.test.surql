-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/execution_timeout.test.surql
-- Fonction     : fn::validation_execution_timeout
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Timeout valide
-- Résultat attendu : 30s
-- ============================================================================
RETURN fn::validation_execution_timeout(
    30s,
    "TIMEOUT",
    1s,
    10m
);

-- ============================================================================
-- TEST 2 — Timeout nul
-- Erreur attendue : TIMEOUT_TIMEOUT_NOT_POSITIVE
-- ============================================================================
RETURN fn::validation_execution_timeout(
    0s,
    "TIMEOUT",
    1s,
    10m
);

-- ============================================================================
-- TEST 3 — Timeout trop long
-- Erreur attendue : TIMEOUT_TIMEOUT_TOO_LONG
-- ============================================================================
RETURN fn::validation_execution_timeout(
    20m,
    "TIMEOUT",
    1s,
    10m
);
