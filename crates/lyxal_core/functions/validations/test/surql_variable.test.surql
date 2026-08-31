-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_variable.test.surql
-- Fonction     : fn::validation_surql_variable
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Variable valide
-- Résultat attendu : "clean_value"
-- ============================================================================
RETURN fn::validation_surql_variable(
    "clean_value",
    "VARIABLE_NAME",
    false
);

-- ============================================================================
-- TEST 2 — Préfixe dollar refusé
-- Erreur attendue : VARIABLE_NAME_DOLLAR_PREFIX_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_surql_variable(
    "$clean_value",
    "VARIABLE_NAME",
    false
);

-- ============================================================================
-- TEST 3 — Variable réservée
-- Erreur attendue : VARIABLE_NAME_RESERVED_VARIABLE_NAME
-- ============================================================================
RETURN fn::validation_surql_variable(
    "before",
    "VARIABLE_NAME",
    false
);
