-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_function.test.surql
-- Fonction     : fn::validation_surql_function
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Fonction namespacée
-- Résultat attendu : "validation::email"
-- ============================================================================
RETURN fn::validation_surql_function(
    "validation::email",
    "FUNCTION_NAME",
    true,
    4
);

-- ============================================================================
-- TEST 2 — Fonction à plusieurs niveaux
-- Résultat attendu : "module::scheduler::run_now"
-- ============================================================================
RETURN fn::validation_surql_function(
    "module::scheduler::run_now",
    "FUNCTION_NAME",
    true,
    4
);

-- ============================================================================
-- TEST 3 — Préfixe fn:: refusé
-- Erreur attendue : FUNCTION_NAME_FN_PREFIX_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_surql_function(
    "fn::validation::email",
    "FUNCTION_NAME",
    true,
    4
);
