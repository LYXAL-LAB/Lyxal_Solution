-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/webhook_path.test.surql
-- Fonction     : fn::validation_webhook_path
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Chemin simple
-- Résultat attendu : "/webhook/stripe"
-- ============================================================================
RETURN fn::validation_webhook_path(
    "/webhook/stripe", "PATH", false, false
);

-- ============================================================================
-- TEST 2 — Paramètre autorisé
-- Résultat attendu : "/webhook/:provider"
-- ============================================================================
RETURN fn::validation_webhook_path(
    "/webhook/:provider", "PATH", true, false
);

-- ============================================================================
-- TEST 3 — Wildcard autorisé
-- Résultat attendu : "/webhook/*"
-- ============================================================================
RETURN fn::validation_webhook_path(
    "/webhook/*", "PATH", false, true
);

-- ============================================================================
-- TEST 4 — Paramètre interdit
-- Erreur attendue : PATH_PATH_PARAMETERS_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_webhook_path(
    "/webhook/:provider", "PATH", false, false
);

-- ============================================================================
-- TEST 5 — Traversée interdite
-- Erreur attendue : PATH_INVALID_WEBHOOK_PATH
-- ============================================================================
RETURN fn::validation_webhook_path(
    "/webhook/../secret", "PATH", false, false
);
