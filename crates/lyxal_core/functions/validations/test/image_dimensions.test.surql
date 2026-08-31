-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/image_dimensions.test.surql
-- Fonction     : fn::validation_image_dimensions
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Full HD valide
-- Résultat attendu : pixels = 2073600
-- ============================================================================
RETURN fn::validation_image_dimensions(
    1920,
    1080,
    "IMAGE",
    1,
    8192,
    1,
    8192,
    50000000
);

-- ============================================================================
-- TEST 2 — Largeur hors plage
-- Erreur attendue : IMAGE_WIDTH_OUT_OF_RANGE
-- ============================================================================
RETURN fn::validation_image_dimensions(
    10000,
    1080,
    "IMAGE",
    1,
    8192,
    1,
    8192,
    NONE
);

-- ============================================================================
-- TEST 3 — Trop de pixels
-- Erreur attendue : IMAGE_PIXEL_COUNT_TOO_LARGE
-- ============================================================================
RETURN fn::validation_image_dimensions(
    8000,
    8000,
    "IMAGE",
    1,
    8192,
    1,
    8192,
    50000000
);
