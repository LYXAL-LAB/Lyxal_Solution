-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/currency_code.test.surql
-- Fonction     : fn::validation_currency_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Euro
-- Résultat attendu : "EUR"
-- ============================================================================
RETURN fn::validation_currency_code(
    "eur",
    "CURRENCY",
    NONE
);

-- ============================================================================
-- TEST 2 — Devise autorisée
-- Résultat attendu : "CHF"
-- ============================================================================
RETURN fn::validation_currency_code(
    "CHF",
    "CURRENCY",
    ["EUR", "CHF", "GBP"]
);

-- ============================================================================
-- TEST 3 — Code trop court
-- Erreur attendue : CURRENCY_INVALID_CURRENCY_CODE
-- ============================================================================
RETURN fn::validation_currency_code(
    "EU",
    "CURRENCY",
    NONE
);

-- ============================================================================
-- TEST 4 — Devise non autorisée
-- Erreur attendue : CURRENCY_CURRENCY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_currency_code(
    "USD",
    "CURRENCY",
    ["EUR", "GBP"]
);
