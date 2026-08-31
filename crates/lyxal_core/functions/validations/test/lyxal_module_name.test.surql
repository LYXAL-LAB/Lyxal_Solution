-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_module_name.test.surql
-- Fonction     : fn::validation_lyxal_module_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Module valide
-- Résultat attendu : "lyxal_scheduler"
-- ============================================================================
RETURN fn::validation_lyxal_module_name(
    "Lyxal_Scheduler",
    "MODULE_NAME",
    ["lyxal_"],
    3,
    100
);

-- ============================================================================
-- TEST 2 — Module métier valide
-- Résultat attendu : "booking_engine"
-- ============================================================================
RETURN fn::validation_lyxal_module_name(
    "booking_engine",
    "MODULE_NAME",
    NONE,
    3,
    100
);

-- ============================================================================
-- TEST 3 — Tiret interdit
-- Erreur attendue : MODULE_NAME_INVALID_MODULE_NAME
-- ============================================================================
RETURN fn::validation_lyxal_module_name(
    "lyxal-scheduler",
    "MODULE_NAME",
    NONE,
    3,
    100
);

-- ============================================================================
-- TEST 4 — Préfixe interdit
-- Erreur attendue : MODULE_NAME_MODULE_PREFIX_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_lyxal_module_name(
    "booking_engine",
    "MODULE_NAME",
    ["lyxal_"],
    3,
    100
);
