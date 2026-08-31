-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_permission_name.test.surql
-- Fonction     : fn::validation_lyxal_permission_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Permission simple
-- Résultat attendu : "booking.read"
-- ============================================================================
RETURN fn::validation_lyxal_permission_name(
    "Booking.Read",
    "PERMISSION",
    ["read", "create", "update", "delete"]
);

-- ============================================================================
-- TEST 2 — Permission détaillée
-- Résultat attendu : "scheduler.job.run"
-- ============================================================================
RETURN fn::validation_lyxal_permission_name(
    "scheduler.job.run",
    "PERMISSION",
    ["read", "run"]
);

-- ============================================================================
-- TEST 3 — Action interdite
-- Erreur attendue : PERMISSION_PERMISSION_ACTION_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_lyxal_permission_name(
    "booking.delete",
    "PERMISSION",
    ["read", "create"]
);

-- ============================================================================
-- TEST 4 — Un seul segment
-- Erreur attendue : PERMISSION_INVALID_PERMISSION_NAME
-- ============================================================================
RETURN fn::validation_lyxal_permission_name(
    "admin",
    "PERMISSION",
    NONE
);
