-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_database.test.surql
-- Fonction     : fn::validation_lyxal_database
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Database valide
-- Résultat attendu : "workspace_main"
-- ============================================================================
RETURN fn::validation_lyxal_database(
    "Workspace_Main",
    "DATABASE",
    2,
    64
);

-- ============================================================================
-- TEST 2 — Chiffres internes
-- Résultat attendu : "client2026"
-- ============================================================================
RETURN fn::validation_lyxal_database(
    "client2026",
    "DATABASE",
    2,
    64
);

-- ============================================================================
-- TEST 3 — Tiret interdit
-- Erreur attendue : DATABASE_INVALID_DATABASE
-- ============================================================================
RETURN fn::validation_lyxal_database(
    "client-france",
    "DATABASE",
    2,
    64
);

-- ============================================================================
-- TEST 4 — Double séparateur
-- Erreur attendue : DATABASE_REPEATED_SEPARATOR
-- ============================================================================
RETURN fn::validation_lyxal_database(
    "client__main",
    "DATABASE",
    2,
    64
);
