-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_storage_path.test.surql
-- Fonction     : fn::validation_lyxal_storage_path
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Chemin module valide
-- Résultat attendu : "modules/scheduler/manifest.surql"
-- ============================================================================
RETURN fn::validation_lyxal_storage_path(
    "modules/scheduler/manifest.surql",
    "STORAGE_PATH",
    "modules",
    true,
    1024
);

-- ============================================================================
-- TEST 2 — Répertoire sans extension
-- Résultat attendu : "assets/images"
-- ============================================================================
RETURN fn::validation_lyxal_storage_path(
    "assets/images",
    "STORAGE_PATH",
    "assets",
    false,
    1024
);

-- ============================================================================
-- TEST 3 — Traversée interdite
-- Erreur attendue : STORAGE_PATH_INVALID_STORAGE_PATH
-- ============================================================================
RETURN fn::validation_lyxal_storage_path(
    "modules/../secret.env",
    "STORAGE_PATH",
    "modules",
    true,
    1024
);

-- ============================================================================
-- TEST 4 — Mauvaise racine
-- Erreur attendue : STORAGE_PATH_STORAGE_ROOT_REQUIRED
-- ============================================================================
RETURN fn::validation_lyxal_storage_path(
    "assets/logo.svg",
    "STORAGE_PATH",
    "modules",
    true,
    1024
);
