-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_strings.test.surql
-- Fonction     : fn::validation_array_strings
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tableau de chaînes valide
-- Résultat attendu : ["rust", "surql"]
-- ============================================================================
RETURN fn::validation_array_strings(
    ["rust", "surql"], "TAGS", false
);

-- ============================================================================
-- TEST 2 — Tableau vide valide
-- Résultat attendu : []
-- ============================================================================
RETURN fn::validation_array_strings([], "TAGS", false);

-- ============================================================================
-- TEST 3 — Entier présent
-- Erreur attendue : TAGS_INVALID_ITEM_TYPE
-- ============================================================================
RETURN fn::validation_array_strings(
    ["rust", 42], "TAGS", false
);

-- ============================================================================
-- TEST 4 — Chaîne blanche interdite
-- Erreur attendue : TAGS_BLANK_ITEM_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_array_strings(
    ["rust", "   "], "TAGS", false
);

-- ============================================================================
-- TEST 5 — Chaîne blanche autorisée
-- Résultat attendu : ["rust", ""]
-- ============================================================================
RETURN fn::validation_array_strings(
    ["rust", ""], "TAGS", true
);
