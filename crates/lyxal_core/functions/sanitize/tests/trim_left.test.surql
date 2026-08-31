-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/trim_left.test.surql
-- Fonction     : fn::sanitize_trim_left
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Espaces de début supprimés
-- Résultat attendu : "Lyxal   "
-- ============================================================================
RETURN fn::sanitize_trim_left(
    "   Lyxal   ",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Espaces de fin conservés
-- Résultat attendu : "Lyxal "
-- ============================================================================
RETURN fn::sanitize_trim_left(
    "Lyxal ",
    "VALUE"
);
