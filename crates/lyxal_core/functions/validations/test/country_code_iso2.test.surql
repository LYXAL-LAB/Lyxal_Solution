-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/country_code_iso2.test.surql
-- Fonction     : fn::validation_country_code_iso2
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — France normalisée
-- Résultat attendu : "FR"
-- ============================================================================
RETURN fn::validation_country_code_iso2(
    "fr",
    "COUNTRY_CODE",
    NONE
);

-- ============================================================================
-- TEST 2 — Pays autorisé
-- Résultat attendu : "BE"
-- ============================================================================
RETURN fn::validation_country_code_iso2(
    "BE",
    "COUNTRY_CODE",
    ["FR", "BE", "LU"]
);

-- ============================================================================
-- TEST 3 — Longueur invalide
-- Erreur attendue : COUNTRY_CODE_INVALID_COUNTRY_CODE
-- ============================================================================
RETURN fn::validation_country_code_iso2(
    "FRA",
    "COUNTRY_CODE",
    NONE
);

-- ============================================================================
-- TEST 4 — Pays non autorisé
-- Erreur attendue : COUNTRY_CODE_COUNTRY_CODE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_country_code_iso2(
    "US",
    "COUNTRY_CODE",
    ["FR", "BE"]
);

-- ============================================================================
-- TEST 5 — Liste autorisée invalide
-- Erreur attendue : VALIDATION_INVALID_ALLOWED_COUNTRY_CODE
-- ============================================================================
RETURN fn::validation_country_code_iso2(
    "FR",
    "COUNTRY_CODE",
    ["FR", "FRA"]
);
