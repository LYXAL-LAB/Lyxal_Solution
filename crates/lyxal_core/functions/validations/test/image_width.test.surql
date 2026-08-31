-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/image_width.test.surql
-- Fonction     : fn::validation_image_width
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Largeur valide
-- Résultat attendu : 1920
-- ============================================================================
RETURN fn::validation_image_width(
    1920,
    "WIDTH",
    1,
    8192
);

-- ============================================================================
-- TEST 2 — Trop étroite
-- Erreur attendue : WIDTH_TOO_NARROW
-- ============================================================================
RETURN fn::validation_image_width(
    100,
    "WIDTH",
    320,
    8192
);

-- ============================================================================
-- TEST 3 — Trop large
-- Erreur attendue : WIDTH_TOO_WIDE
-- ============================================================================
RETURN fn::validation_image_width(
    10000,
    "WIDTH",
    1,
    8192
);
