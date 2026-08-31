-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/country_code_iso3.test.surql
-- Fonction     : fn::validation_country_code_iso3
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — France
-- Résultat attendu : "FRA"
-- ============================================================================
RETURN fn::validation_country_code_iso3(
    "fra",
    "COUNTRY_CODE",
    NONE
);

-- ============================================================================
-- TEST 2 — Code autorisé
-- Résultat attendu : "BEL"
-- ============================================================================
RETURN fn::validation_country_code_iso3(
    "BEL",
    "COUNTRY_CODE",
    ["FRA", "BEL", "LUX"]
);

-- ============================================================================
-- TEST 3 — Alpha-2 refusé
-- Erreur attendue : COUNTRY_CODE_INVALID_COUNTRY_CODE
-- ============================================================================
RETURN fn::validation_country_code_iso3(
    "FR",
    "COUNTRY_CODE",
    NONE
);

-- ============================================================================
-- TEST 4 — Code non autorisé
-- Erreur attendue : COUNTRY_CODE_COUNTRY_CODE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_country_code_iso3(
    "USA",
    "COUNTRY_CODE",
    ["FRA", "BEL"]
);
