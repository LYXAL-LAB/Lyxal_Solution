-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/trim.test.surql
-- Fonction     : fn::sanitize_trim
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Espaces extérieurs
-- Résultat attendu : "Lyxal"
-- ============================================================================
RETURN fn::sanitize_trim(
    "   Lyxal   ",
    "VALUE"
);

-- ============================================================================
-- TEST 2 — Espaces internes conservés
-- Résultat attendu : "Lyxal OS"
-- ============================================================================
RETURN fn::sanitize_trim(
    "  Lyxal OS  ",
    "VALUE"
);

-- ============================================================================
-- TEST 3 — Type invalide
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================
RETURN fn::sanitize_trim(
    42,
    "VALUE"
);
