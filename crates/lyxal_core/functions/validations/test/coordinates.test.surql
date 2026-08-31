-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/coordinates.test.surql
-- Fonction     : fn::validation_coordinates
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Coordonnées de Paris
-- Résultat attendu : { latitude: 48.8566, longitude: 2.3522 }
-- ============================================================================
RETURN fn::validation_coordinates(
    48.8566,
    2.3522,
    "COORDINATES"
);

-- ============================================================================
-- TEST 2 — Origine géographique
-- Résultat attendu : { latitude: 0, longitude: 0 }
-- ============================================================================
RETURN fn::validation_coordinates(
    0,
    0,
    "COORDINATES"
);

-- ============================================================================
-- TEST 3 — Latitude hors plage
-- Erreur attendue : COORDINATES_LATITUDE_OUT_OF_RANGE
-- ============================================================================
RETURN fn::validation_coordinates(
    91,
    2.3522,
    "COORDINATES"
);

-- ============================================================================
-- TEST 4 — Longitude absente
-- Erreur attendue : COORDINATES_LONGITUDE_REQUIRED
-- ============================================================================
RETURN fn::validation_coordinates(
    48.8566,
    NONE,
    "COORDINATES"
);
