-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/capitalize.test.surql
-- Fonction     : fn::sanitize_capitalize
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Mot en majuscules
-- Résultat attendu : "Lyxal"
-- ============================================================================
RETURN fn::sanitize_capitalize(
    "LYXAL",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Phrase
-- Résultat attendu : "Lyxal os"
-- ============================================================================
RETURN fn::sanitize_capitalize(
    "lyxal OS",
    "VALUE"
);

-- ============================================================================
-- TEST 3 — Chaîne vide
-- Résultat attendu : ""
-- ============================================================================
RETURN fn::sanitize_capitalize(
    "",
    "VALUE"
);
