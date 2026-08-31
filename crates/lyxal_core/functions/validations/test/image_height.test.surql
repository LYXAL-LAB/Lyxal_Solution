-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/image_height.test.surql
-- Fonction     : fn::validation_image_height
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Hauteur valide
-- Résultat attendu : 1080
-- ============================================================================
RETURN fn::validation_image_height(
    1080,
    "HEIGHT",
    1,
    8192
);

-- ============================================================================
-- TEST 2 — Trop petite
-- Erreur attendue : HEIGHT_TOO_SHORT
-- ============================================================================
RETURN fn::validation_image_height(
    100,
    "HEIGHT",
    320,
    8192
);

-- ============================================================================
-- TEST 3 — Trop grande
-- Erreur attendue : HEIGHT_TOO_TALL
-- ============================================================================
RETURN fn::validation_image_height(
    10000,
    "HEIGHT",
    1,
    8192
);
