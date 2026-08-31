-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_parameter.test.surql
-- Fonction     : fn::validation_surql_parameter
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Paramètre valide
-- Résultat attendu : "api_base_url"
-- ============================================================================
RETURN fn::validation_surql_parameter(
    "api_base_url",
    "PARAMETER_NAME",
    false
);

-- ============================================================================
-- TEST 2 — Préfixe dollar refusé
-- Erreur attendue : PARAMETER_NAME_DOLLAR_PREFIX_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_surql_parameter(
    "$api_base_url",
    "PARAMETER_NAME",
    false
);

-- ============================================================================
-- TEST 3 — Nom réservé
-- Erreur attendue : PARAMETER_NAME_RESERVED_PARAMETER_NAME
-- ============================================================================
RETURN fn::validation_surql_parameter(
    "auth",
    "PARAMETER_NAME",
    false
);
