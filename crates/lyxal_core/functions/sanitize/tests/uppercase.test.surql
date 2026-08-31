-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/uppercase.test.surql
-- Fonction     : fn::sanitize_uppercase
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Minuscules
-- Résultat attendu : "LYXAL OS"
-- ============================================================================
RETURN fn::sanitize_uppercase(
    "lyxal os",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Accents
-- Résultat attendu : "ÉQUIPE"
-- ============================================================================
RETURN fn::sanitize_uppercase(
    "équipe",
    "VALUE"
);
