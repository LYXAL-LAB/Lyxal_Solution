-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/alphanumeric.test.surql
-- Fonction     : fn::validation_alphanumeric
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
-- TEST 1 — Lettres et chiffres
-- Résultat attendu : "Lyxal2026"
-- ============================================================================
RETURN fn::validation_alphanumeric(
    "Lyxal2026", "CODE", true
);

-- ============================================================================
-- TEST 2 — Lettres uniquement
-- Résultat attendu : "Lyxal"
-- ============================================================================
RETURN fn::validation_alphanumeric(
    "Lyxal", "CODE", true
);

-- ============================================================================
-- TEST 3 — Chiffres uniquement
-- Résultat attendu : "2026"
-- ============================================================================
RETURN fn::validation_alphanumeric(
    "2026", "CODE", true
);

-- ============================================================================
-- TEST 4 — Tiret interdit
-- Erreur attendue : CODE_INVALID_ALPHANUMERIC
-- ============================================================================
RETURN fn::validation_alphanumeric(
    "Lyxal-2026", "CODE", true
);

-- ============================================================================
-- TEST 5 — Espace interne interdit
-- Erreur attendue : CODE_INVALID_ALPHANUMERIC
-- ============================================================================
RETURN fn::validation_alphanumeric(
    "Lyxal 2026", "CODE", true
);

-- ============================================================================
-- TEST 6 — Chaîne vide
-- Erreur attendue : CODE_BLANK_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_alphanumeric(
    "", "CODE", true
);
