-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/retry_policy.test.surql
-- Fonction     : fn::validation_retry_policy
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Retry exponentiel valide
-- Résultat attendu : objet normalisé
-- ============================================================================
RETURN fn::validation_retry_policy(
    {
        max_attempts: 5,
        strategy: "exponential",
        initial_delay: 1s,
        max_delay: 5m
    },
    "RETRY_POLICY",
    20,
    10m
);

-- ============================================================================
-- TEST 2 — Clé obligatoire manquante
-- Erreur attendue : RETRY_POLICY_MISSING_REQUIRED_KEY
-- ============================================================================
RETURN fn::validation_retry_policy(
    {
        max_attempts: 5,
        strategy: "fixed"
    },
    "RETRY_POLICY",
    20,
    10m
);

-- ============================================================================
-- TEST 3 — Stratégie invalide
-- Erreur attendue : RETRY_POLICY_INVALID_RETRY_STRATEGY
-- ============================================================================
RETURN fn::validation_retry_policy(
    {
        max_attempts: 5,
        strategy: "random",
        initial_delay: 1s
    },
    "RETRY_POLICY",
    20,
    10m
);
