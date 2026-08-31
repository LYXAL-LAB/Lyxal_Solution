-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/postal_code_fr.test.surql
-- Fonction     : fn::validation_postal_code_fr
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Code postal standard
-- Résultat attendu : "46000"
-- ============================================================================
RETURN fn::validation_postal_code_fr(
    "46000",
    "POSTAL_CODE",
    false
);

-- ============================================================================
-- TEST 2 — Paris
-- Résultat attendu : "75001"
-- ============================================================================
RETURN fn::validation_postal_code_fr(
    "75001",
    "POSTAL_CODE",
    false
);

-- ============================================================================
-- TEST 3 — CEDEX autorisé
-- Résultat attendu : "75008 CEDEX 08"
-- ============================================================================
RETURN fn::validation_postal_code_fr(
    "75008 cedex 08",
    "POSTAL_CODE",
    true
);

-- ============================================================================
-- TEST 4 — CEDEX interdit
-- Erreur attendue : POSTAL_CODE_INVALID_POSTAL_CODE
-- ============================================================================
RETURN fn::validation_postal_code_fr(
    "75008 CEDEX",
    "POSTAL_CODE",
    false
);

-- ============================================================================
-- TEST 5 — Longueur invalide
-- Erreur attendue : POSTAL_CODE_INVALID_POSTAL_CODE
-- ============================================================================
RETURN fn::validation_postal_code_fr(
    "4600",
    "POSTAL_CODE",
    false
);
