-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/aspect_ratio.test.surql
-- Fonction     : fn::validation_aspect_ratio
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Ratio 16:9 valide
-- Résultat attendu : ratio proche de 1.777...
-- ============================================================================
RETURN fn::validation_aspect_ratio(
    1920,
    1080,
    "IMAGE",
    1.7dec,
    1.8dec
);

-- ============================================================================
-- TEST 2 — Ratio trop petit
-- Erreur attendue : IMAGE_RATIO_TOO_SMALL
-- ============================================================================
RETURN fn::validation_aspect_ratio(
    1000,
    2000,
    "IMAGE",
    1dec,
    2dec
);

-- ============================================================================
-- TEST 3 — Hauteur nulle
-- Erreur attendue : IMAGE_INVALID_DIMENSION_VALUE
-- ============================================================================
RETURN fn::validation_aspect_ratio(
    1920,
    0,
    "IMAGE",
    1dec,
    2dec
);
