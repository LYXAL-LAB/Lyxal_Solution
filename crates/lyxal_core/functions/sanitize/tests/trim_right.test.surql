-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/trim_right.test.surql
-- Fonction     : fn::sanitize_trim_right
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Espaces de fin supprimés
-- Résultat attendu : "   Lyxal"
-- ============================================================================
RETURN fn::sanitize_trim_right(
    "   Lyxal   ",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Espaces de début conservés
-- Résultat attendu : " Lyxal"
-- ============================================================================
RETURN fn::sanitize_trim_right(
    " Lyxal",
    "VALUE"
);
