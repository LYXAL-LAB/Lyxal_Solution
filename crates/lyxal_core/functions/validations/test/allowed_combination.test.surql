-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/allowed_combination.test.surql
-- Fonction     : fn::validation_allowed_combination
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Combinaison autorisée
-- Résultat attendu : ["email", "daily"]
-- ============================================================================
RETURN fn::validation_allowed_combination(
    ["email", "daily"],
    "NOTIFICATION_SETTINGS",
    [
        ["email", "daily"],
        ["email", "weekly"],
        ["sms", "urgent"]
    ]
);

-- ============================================================================
-- TEST 2 — Combinaison interdite
-- Erreur attendue : NOTIFICATION_SETTINGS_COMBINATION_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_allowed_combination(
    ["sms", "daily"],
    "NOTIFICATION_SETTINGS",
    [
        ["email", "daily"],
        ["sms", "urgent"]
    ]
);
