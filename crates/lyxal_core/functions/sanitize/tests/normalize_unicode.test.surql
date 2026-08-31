-- ============================================================================
-- LYXAL OS — TESTS CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/tests/normalize_unicode.test.surql
-- Fonction     : fn::sanitize_normalize_unicode
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Espace insécable
-- Résultat attendu : "Lyxal OS"
-- ============================================================================
RETURN fn::sanitize_normalize_unicode(
    "Lyxal OS",
    "VALUE",
    false
);

-- ============================================================================
-- TEST 2 — Zero-width supprimé
-- Résultat attendu : "LyxalOS"
-- ============================================================================
RETURN fn::sanitize_normalize_unicode(
    "Lyxal​OS",
    "VALUE",
    false
);

-- ============================================================================
-- TEST 3 — Espaces regroupés
-- Résultat attendu : "Lyxal OS Core"
-- ============================================================================
RETURN fn::sanitize_normalize_unicode(
    "  Lyxal  OS   Core  ",
    "VALUE",
    true
);
