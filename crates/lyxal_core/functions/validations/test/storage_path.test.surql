-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/storage_path.test.surql
-- Fonction     : fn::validation_storage_path
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Chemin valide
-- Résultat attendu : "modules/scheduler/manifest.surql"
-- ============================================================================
RETURN fn::validation_storage_path(
    "modules/scheduler/manifest.surql",
    "STORAGE_PATH",
    false,
    false,
    1024
);

-- ============================================================================
-- TEST 2 — Slash initial autorisé
-- Résultat attendu : "/assets/logo.svg"
-- ============================================================================
RETURN fn::validation_storage_path(
    "/assets/logo.svg",
    "STORAGE_PATH",
    true,
    false,
    1024
);

-- ============================================================================
-- TEST 3 — Traversée interdite
-- Erreur attendue : STORAGE_PATH_INVALID_STORAGE_PATH
-- ============================================================================
RETURN fn::validation_storage_path(
    "modules/../secret.env",
    "STORAGE_PATH",
    false,
    false,
    1024
);

-- ============================================================================
-- TEST 4 — Backslash interdit
-- Erreur attendue : STORAGE_PATH_INVALID_STORAGE_PATH
-- ============================================================================
RETURN fn::validation_storage_path(
    "modules\scheduler\file.surql",
    "STORAGE_PATH",
    false,
    false,
    1024
);
