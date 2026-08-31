-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lowercase.test.surql
-- Fonction     : fn::validation_lowercase
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
-- TEST 1 — Minuscules valides
-- Résultat attendu : "lyxal-core"
-- ============================================================================
RETURN fn::validation_lowercase(
    "lyxal-core", "IDENTIFIER", true, false
);

-- ============================================================================
-- TEST 2 — Majuscule présente
-- Erreur attendue : IDENTIFIER_NOT_LOWERCASE
-- ============================================================================
RETURN fn::validation_lowercase(
    "Lyxal-core", "IDENTIFIER", true, false
);

-- ============================================================================
-- TEST 3 — Chiffres et ponctuation acceptés
-- Résultat attendu : "lyxal_2026"
-- ============================================================================
RETURN fn::validation_lowercase(
    "lyxal_2026", "IDENTIFIER", true, false
);

-- ============================================================================
-- TEST 4 — Chaîne vide refusée
-- Erreur attendue : IDENTIFIER_BLANK_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_lowercase(
    "", "IDENTIFIER", true, false
);

-- ============================================================================
-- TEST 5 — Chaîne vide autorisée
-- Résultat attendu : ""
-- ============================================================================
RETURN fn::validation_lowercase(
    "", "IDENTIFIER", true, true
);
