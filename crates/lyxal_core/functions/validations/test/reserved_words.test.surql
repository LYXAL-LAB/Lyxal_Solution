-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/reserved_words.test.surql
-- Fonction     : fn::validation_reserved_words
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
-- TEST 1 — Identifiant disponible
-- Résultat attendu : "yaniss"
-- ============================================================================
RETURN fn::validation_reserved_words(
    "yaniss", "USERNAME", ["admin", "root", "system"], true
);

-- ============================================================================
-- TEST 2 — Mot réservé
-- Erreur attendue : USERNAME_RESERVED_WORD
-- ============================================================================
RETURN fn::validation_reserved_words(
    "admin", "USERNAME", ["admin", "root"], true
);

-- ============================================================================
-- TEST 3 — Mot réservé avec casse différente
-- Erreur attendue : USERNAME_RESERVED_WORD
-- ============================================================================
RETURN fn::validation_reserved_words(
    "ADMIN", "USERNAME", ["admin"], true
);

-- ============================================================================
-- TEST 4 — Mot composé non égal au mot réservé
-- Résultat attendu : "administrator"
-- ============================================================================
RETURN fn::validation_reserved_words(
    "administrator", "USERNAME", ["admin"], true
);

-- ============================================================================
-- TEST 5 — Liste vide
-- Erreur attendue : VALIDATION_EMPTY_RESERVED_WORDS
-- ============================================================================
RETURN fn::validation_reserved_words(
    "yaniss", "USERNAME", [], true
);
