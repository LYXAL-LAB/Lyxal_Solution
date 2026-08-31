-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/lowercase.test.surql
-- Fonction     : fn::sanitize_lowercase
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Majuscules
-- Résultat attendu : "lyxal os"
-- ============================================================================
RETURN fn::sanitize_lowercase(
    "LYXAL OS",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Accents
-- Résultat attendu : "équipe"
-- ============================================================================
RETURN fn::sanitize_lowercase(
    "ÉQUIPE",
    "VALUE"
);
