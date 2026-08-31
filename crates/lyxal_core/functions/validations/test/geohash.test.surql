-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/geohash.test.surql
-- Fonction     : fn::validation_geohash
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Géohash valide
-- Résultat attendu : "u09tvw0f64"
-- ============================================================================
RETURN fn::validation_geohash(
    "U09TVW0F64",
    "GEOHASH",
    1,
    12
);

-- ============================================================================
-- TEST 2 — Caractère interdit
-- Erreur attendue : GEOHASH_INVALID_GEOHASH
-- ============================================================================
RETURN fn::validation_geohash(
    "u09tiw",
    "GEOHASH",
    1,
    12
);

-- ============================================================================
-- TEST 3 — Trop long
-- Erreur attendue : GEOHASH_TOO_LONG
-- ============================================================================
RETURN fn::validation_geohash(
    "u09tvw0f64abc",
    "GEOHASH",
    1,
    12
);
