-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_function_name.test.surql
-- Fonction     : fn::validation_lyxal_function_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Fonction namespacée
-- Résultat attendu : "validation::email"
-- ============================================================================
RETURN fn::validation_lyxal_function_name(
    "Validation::Email",
    "FUNCTION_NAME",
    true,
    150
);

-- ============================================================================
-- TEST 2 — Plusieurs niveaux
-- Résultat attendu : "module::scheduler::run_now"
-- ============================================================================
RETURN fn::validation_lyxal_function_name(
    "module::scheduler::run_now",
    "FUNCTION_NAME",
    true,
    150
);

-- ============================================================================
-- TEST 3 — Namespace manquant
-- Erreur attendue : FUNCTION_NAME_FUNCTION_NAMESPACE_REQUIRED
-- ============================================================================
RETURN fn::validation_lyxal_function_name(
    "run_now",
    "FUNCTION_NAME",
    true,
    150
);

-- ============================================================================
-- TEST 4 — Tiret interdit
-- Erreur attendue : FUNCTION_NAME_INVALID_FUNCTION_NAME
-- ============================================================================
RETURN fn::validation_lyxal_function_name(
    "scheduler::run-now",
    "FUNCTION_NAME",
    true,
    150
);
