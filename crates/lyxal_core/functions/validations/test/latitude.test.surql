-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/latitude.test.surql
-- Fonction     : fn::validation_latitude
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Latitude de Paris
-- Résultat attendu : 48.8566
-- ============================================================================
RETURN fn::validation_latitude(
    48.8566,
    "LATITUDE"
);

-- ============================================================================
-- TEST 2 — Pôle Nord
-- Résultat attendu : 90
-- ============================================================================
RETURN fn::validation_latitude(
    90,
    "LATITUDE"
);

-- ============================================================================
-- TEST 3 — Trop au nord
-- Erreur attendue : LATITUDE_LATITUDE_OUT_OF_RANGE
-- ============================================================================
RETURN fn::validation_latitude(
    90.0001,
    "LATITUDE"
);

-- ============================================================================
-- TEST 4 — Chaîne refusée
-- Erreur attendue : LATITUDE_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_latitude(
    "48.8566",
    "LATITUDE"
);
