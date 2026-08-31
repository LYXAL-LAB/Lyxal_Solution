-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/starts_with.test.surql
-- Fonction     : fn::validation_starts_with
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
-- TEST 1 — Préfixe valide
-- Résultat attendu : "lyxal-core"
-- ============================================================================
RETURN fn::validation_starts_with(
    "lyxal-core", "IDENTIFIER", ["lyxal-"], true, true
);

-- ============================================================================
-- TEST 2 — Comparaison insensible à la casse
-- Résultat attendu : "Lyxal-Core"
-- ============================================================================
RETURN fn::validation_starts_with(
    "Lyxal-Core", "IDENTIFIER", ["lyxal-"], false, true
);

-- ============================================================================
-- TEST 3 — Plusieurs préfixes autorisés
-- Résultat attendu : "https://lyxal.test"
-- ============================================================================
RETURN fn::validation_starts_with(
    "https://lyxal.test", "URL", ["http://", "https://"], true, true
);

-- ============================================================================
-- TEST 4 — Préfixe invalide
-- Erreur attendue : IDENTIFIER_INVALID_PREFIX
-- ============================================================================
RETURN fn::validation_starts_with(
    "core-lyxal", "IDENTIFIER", ["lyxal-"], true, true
);

-- ============================================================================
-- TEST 5 — Liste vide
-- Erreur attendue : VALIDATION_EMPTY_PREFIXES
-- ============================================================================
RETURN fn::validation_starts_with(
    "lyxal-core", "IDENTIFIER", [], true, true
);

-- ============================================================================
-- TEST 6 — Préfixe vide
-- Erreur attendue : VALIDATION_INVALID_PREFIX
-- ============================================================================
RETURN fn::validation_starts_with(
    "lyxal-core", "IDENTIFIER", ["   "], true, true
);

-- ============================================================================
-- TEST 7 — Valeur absente
-- Erreur attendue : IDENTIFIER_REQUIRED
-- ============================================================================
RETURN fn::validation_starts_with(
    NONE, "IDENTIFIER", ["lyxal-"], true, true
);

-- ============================================================================
-- TEST 8 — Type invalide
-- Erreur attendue : IDENTIFIER_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_starts_with(
    42, "IDENTIFIER", ["lyxal-"], true, true
);

-- ============================================================================
-- TEST 9 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================
RETURN fn::validation_starts_with(
    "lyxal-core", "   ", ["lyxal-"], true, true
);
