-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/longitude.test.surql
-- Fonction     : fn::validation_longitude
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Longitude de Paris
-- Résultat attendu : 2.3522
-- ============================================================================
RETURN fn::validation_longitude(
    2.3522,
    "LONGITUDE"
);

-- ============================================================================
-- TEST 2 — Limite ouest
-- Résultat attendu : -180
-- ============================================================================
RETURN fn::validation_longitude(
    -180,
    "LONGITUDE"
);

-- ============================================================================
-- TEST 3 — Hors plage
-- Erreur attendue : LONGITUDE_LONGITUDE_OUT_OF_RANGE
-- ============================================================================
RETURN fn::validation_longitude(
    180.0001,
    "LONGITUDE"
);

-- ============================================================================
-- TEST 4 — Booléen refusé
-- Erreur attendue : LONGITUDE_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_longitude(
    true,
    "LONGITUDE"
);
