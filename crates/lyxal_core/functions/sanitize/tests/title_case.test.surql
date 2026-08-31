-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/title_case.test.surql
-- Fonction     : fn::sanitize_title_case
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Phrase
-- Résultat attendu : "Lyxal Operating System"
-- ============================================================================
RETURN fn::sanitize_title_case(
    "LYXAL operating SYSTEM",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Plusieurs mots
-- Résultat attendu : "Jean Pierre"
-- ============================================================================
RETURN fn::sanitize_title_case(
    "jean pierre",
    "VALUE"
);
