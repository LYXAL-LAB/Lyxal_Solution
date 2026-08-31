-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/archive_entry_path.test.surql
-- Fonction     : fn::validation_archive_entry_path
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Entrée valide
-- Résultat attendu : "folder/file.txt"
-- ============================================================================
RETURN fn::validation_archive_entry_path(
    "folder/file.txt",
    "ENTRY_PATH",
    1024
);

-- ============================================================================
-- TEST 2 — Traversée Unix
-- Erreur attendue : ENTRY_PATH_INVALID_ARCHIVE_ENTRY_PATH
-- ============================================================================
RETURN fn::validation_archive_entry_path(
    "../../etc/passwd",
    "ENTRY_PATH",
    1024
);

-- ============================================================================
-- TEST 3 — Chemin absolu Windows
-- Erreur attendue : ENTRY_PATH_INVALID_ARCHIVE_ENTRY_PATH
-- ============================================================================
RETURN fn::validation_archive_entry_path(
    "C:\Windows\system.ini",
    "ENTRY_PATH",
    1024
);
