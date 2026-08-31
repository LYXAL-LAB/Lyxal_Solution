-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/contains.test.surql
-- Fonction     : fn::validation_contains
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
-- TEST 1 — Sous-chaîne présente
-- Résultat attendu : "Lyxal Operating System"
-- ============================================================================
RETURN fn::validation_contains(
    "Lyxal Operating System", "TITLE", ["Operating"], true, true
);

-- ============================================================================
-- TEST 2 — Recherche insensible à la casse
-- Résultat attendu : "Lyxal Operating System"
-- ============================================================================
RETURN fn::validation_contains(
    "Lyxal Operating System", "TITLE", ["operating"], false, true
);

-- ============================================================================
-- TEST 3 — Une valeur parmi plusieurs est présente
-- Résultat attendu : "module scheduler"
-- ============================================================================
RETURN fn::validation_contains(
    "module scheduler", "DESCRIPTION", ["calendar", "scheduler"], true, true
);

-- ============================================================================
-- TEST 4 — Contenu absent
-- Erreur attendue : TITLE_REQUIRED_CONTENT_MISSING
-- ============================================================================
RETURN fn::validation_contains(
    "Lyxal OS", "TITLE", ["Scheduler"], false, true
);

-- ============================================================================
-- TEST 5 — Liste vide
-- Erreur attendue : VALIDATION_EMPTY_NEEDLES
-- ============================================================================
RETURN fn::validation_contains(
    "Lyxal OS", "TITLE", [], true, true
);

-- ============================================================================
-- TEST 6 — Sous-chaîne vide
-- Erreur attendue : VALIDATION_INVALID_NEEDLE
-- ============================================================================
RETURN fn::validation_contains(
    "Lyxal OS", "TITLE", [""], true, true
);
