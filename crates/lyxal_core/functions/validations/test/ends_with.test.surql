-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/ends_with.test.surql
-- Fonction     : fn::validation_ends_with
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
-- TEST 1 — Extension valide
-- Résultat attendu : "document.pdf"
-- ============================================================================
RETURN fn::validation_ends_with(
    "document.pdf", "FILENAME", [".pdf"], true, true
);

-- ============================================================================
-- TEST 2 — Plusieurs extensions autorisées
-- Résultat attendu : "PHOTO.JPG"
-- ============================================================================
RETURN fn::validation_ends_with(
    "PHOTO.JPG", "FILENAME", [".jpg", ".png"], false, true
);

-- ============================================================================
-- TEST 3 — Suffixe invalide
-- Erreur attendue : FILENAME_INVALID_SUFFIX
-- ============================================================================
RETURN fn::validation_ends_with(
    "document.exe", "FILENAME", [".pdf"], false, true
);

-- ============================================================================
-- TEST 4 — Liste vide
-- Erreur attendue : VALIDATION_EMPTY_SUFFIXES
-- ============================================================================
RETURN fn::validation_ends_with(
    "document.pdf", "FILENAME", [], true, true
);

-- ============================================================================
-- TEST 5 — Suffixe vide
-- Erreur attendue : VALIDATION_INVALID_SUFFIX
-- ============================================================================
RETURN fn::validation_ends_with(
    "document.pdf", "FILENAME", ["  "], true, true
);

-- ============================================================================
-- TEST 6 — Valeur NULL
-- Erreur attendue : FILENAME_NULL_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_ends_with(
    NULL, "FILENAME", [".pdf"], true, true
);

-- ============================================================================
-- TEST 7 — Type invalide
-- Erreur attendue : FILENAME_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_ends_with(
    ["document.pdf"], "FILENAME", [".pdf"], true, true
);
