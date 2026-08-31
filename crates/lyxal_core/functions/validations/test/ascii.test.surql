-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/ascii.test.surql
-- Fonction     : fn::validation_ascii
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution.
-- Dans Surrealist, sélectionner individuellement le test concerné lorsqu'une
-- erreur est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — ASCII valide
-- Résultat attendu : "LYXAL-2026_test"
-- ============================================================================
RETURN fn::validation_ascii(
    "LYXAL-2026_test", "VALUE", true, false
);

-- ============================================================================
-- TEST 2 — Accents refusés
-- Erreur attendue : VALUE_NON_ASCII_CHARACTERS
-- ============================================================================
RETURN fn::validation_ascii(
    "Équipe", "VALUE", true, false
);

-- ============================================================================
-- TEST 3 — Emoji refusé
-- Erreur attendue : VALUE_NON_ASCII_CHARACTERS
-- ============================================================================
RETURN fn::validation_ascii(
    "Lyxal 🚀", "VALUE", true, false
);

-- ============================================================================
-- TEST 4 — Chaîne vide autorisée
-- Résultat attendu : ""
-- ============================================================================
RETURN fn::validation_ascii(
    "", "VALUE", true, true
);

-- ============================================================================
-- TEST 5 — Type invalide
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_ascii(
    2026, "VALUE", true, false
);
