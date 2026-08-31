-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/content_disposition_filename.test.surql
-- Fonction     : fn::validation_content_disposition_filename
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nom valide
-- Résultat attendu : "rapport-2026.pdf"
-- ============================================================================
RETURN fn::validation_content_disposition_filename(
    "rapport-2026.pdf",
    "FILENAME",
    255
);

-- ============================================================================
-- TEST 2 — Guillemet interdit
-- Erreur attendue : FILENAME_INVALID_CONTENT_DISPOSITION_FILENAME
-- ============================================================================
RETURN fn::validation_content_disposition_filename(
    "rapport\"2026.pdf",
    "FILENAME",
    255
);

-- ============================================================================
-- TEST 3 — Injection CRLF interdite
-- Erreur attendue : FILENAME_INVALID_CONTENT_DISPOSITION_FILENAME
-- ============================================================================
RETURN fn::validation_content_disposition_filename(
    "rapport.pdf\r\nX-Test: injected",
    "FILENAME",
    255
);

-- ============================================================================
-- TEST 4 — Chemin interdit
-- Erreur attendue : FILENAME_INVALID_CONTENT_DISPOSITION_FILENAME
-- ============================================================================
RETURN fn::validation_content_disposition_filename(
    "../rapport.pdf",
    "FILENAME",
    255
);
