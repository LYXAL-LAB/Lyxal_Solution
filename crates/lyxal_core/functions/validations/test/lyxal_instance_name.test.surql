-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_instance_name.test.surql
-- Fonction     : fn::validation_lyxal_instance_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Instance production
-- Résultat attendu : "lyxal-main-prod"
-- ============================================================================
RETURN fn::validation_lyxal_instance_name(
    "Lyxal-Main-Prod",
    "INSTANCE_NAME",
    "prod",
    3,
    100
);

-- ============================================================================
-- TEST 2 — Marque blanche
-- Résultat attendu : "client-alpha-staging"
-- ============================================================================
RETURN fn::validation_lyxal_instance_name(
    "client-alpha-staging",
    "INSTANCE_NAME",
    "staging",
    3,
    100
);

-- ============================================================================
-- TEST 3 — Mauvais suffixe
-- Erreur attendue : INSTANCE_NAME_ENVIRONMENT_SUFFIX_REQUIRED
-- ============================================================================
RETURN fn::validation_lyxal_instance_name(
    "lyxal-main-dev",
    "INSTANCE_NAME",
    "prod",
    3,
    100
);

-- ============================================================================
-- TEST 4 — Environnement inconnu
-- Erreur attendue : VALIDATION_INVALID_INSTANCE_ENVIRONMENT
-- ============================================================================
RETURN fn::validation_lyxal_instance_name(
    "lyxal-main-local",
    "INSTANCE_NAME",
    "local",
    3,
    100
);
