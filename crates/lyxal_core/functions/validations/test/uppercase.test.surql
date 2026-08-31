-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/uppercase.test.surql
-- Fonction     : fn::validation_uppercase
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
-- TEST 1 — Majuscules valides
-- Résultat attendu : "LYXAL_CORE"
-- ============================================================================
RETURN fn::validation_uppercase(
    "LYXAL_CORE", "CODE", true, false
);

-- ============================================================================
-- TEST 2 — Minuscule présente
-- Erreur attendue : CODE_NOT_UPPERCASE
-- ============================================================================
RETURN fn::validation_uppercase(
    "LYXAL_Core", "CODE", true, false
);

-- ============================================================================
-- TEST 3 — Chiffres et ponctuation acceptés
-- Résultat attendu : "LYXAL-2026"
-- ============================================================================
RETURN fn::validation_uppercase(
    "LYXAL-2026", "CODE", true, false
);

-- ============================================================================
-- TEST 4 — Chaîne vide refusée
-- Erreur attendue : CODE_BLANK_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_uppercase(
    "", "CODE", true, false
);
