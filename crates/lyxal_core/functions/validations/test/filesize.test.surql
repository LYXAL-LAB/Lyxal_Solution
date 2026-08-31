-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/filesize.test.surql
-- Fonction     : fn::validation_filesize
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Taille valide
-- Résultat attendu : 1048576
-- ============================================================================
RETURN fn::validation_filesize(
    1048576,
    "FILE_SIZE",
    1,
    10485760
);

-- ============================================================================
-- TEST 2 — Fichier vide autorisé
-- Résultat attendu : 0
-- ============================================================================
RETURN fn::validation_filesize(
    0,
    "FILE_SIZE",
    0,
    NONE
);

-- ============================================================================
-- TEST 3 — Taille trop élevée
-- Erreur attendue : FILE_SIZE_TOO_LARGE
-- ============================================================================
RETURN fn::validation_filesize(
    10485761,
    "FILE_SIZE",
    1,
    10485760
);

-- ============================================================================
-- TEST 4 — Decimal refusé
-- Erreur attendue : FILE_SIZE_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_filesize(
    1024dec,
    "FILE_SIZE",
    0,
    NONE
);
