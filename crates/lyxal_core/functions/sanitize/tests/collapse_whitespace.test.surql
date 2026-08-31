-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/collapse_whitespace.test.surql
-- Fonction     : fn::sanitize_collapse_whitespace
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Espaces multiples
-- Résultat attendu : "Lyxal OS"
-- ============================================================================
RETURN fn::sanitize_collapse_whitespace(
    "  Lyxal    OS  ",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Tabulation et retour à la ligne
-- Résultat attendu : "Lyxal OS Core"
-- ============================================================================
RETURN fn::sanitize_collapse_whitespace(
    "Lyxal	OS
Core",
    "VALUE"
);
