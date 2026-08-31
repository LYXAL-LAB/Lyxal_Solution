-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_role_name.test.surql
-- Fonction     : fn::validation_lyxal_role_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Rôle valide
-- Résultat attendu : "project_manager"
-- ============================================================================
RETURN fn::validation_lyxal_role_name(
    "Project_Manager",
    "ROLE_NAME",
    ["root", "system"],
    2,
    64
);

-- ============================================================================
-- TEST 2 — Rôle réservé
-- Erreur attendue : ROLE_NAME_RESERVED_ROLE_NAME
-- ============================================================================
RETURN fn::validation_lyxal_role_name(
    "root",
    "ROLE_NAME",
    ["root", "system"],
    2,
    64
);

-- ============================================================================
-- TEST 3 — Tiret interdit
-- Erreur attendue : ROLE_NAME_INVALID_ROLE_NAME
-- ============================================================================
RETURN fn::validation_lyxal_role_name(
    "project-manager",
    "ROLE_NAME",
    NONE,
    2,
    64
);
