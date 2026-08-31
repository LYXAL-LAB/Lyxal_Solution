-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/required_unless.test.surql
-- Fonction     : fn::validation_required_unless
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Exception vraie
-- Résultat attendu : NONE
-- ============================================================================
RETURN fn::validation_required_unless(
    NONE,
    "PHONE",
    true,
    false
);

-- ============================================================================
-- TEST 2 — Exception fausse et valeur présente
-- Résultat attendu : "+33123456789"
-- ============================================================================
RETURN fn::validation_required_unless(
    "+33123456789",
    "PHONE",
    false,
    false
);

-- ============================================================================
-- TEST 3 — Exception fausse et valeur absente
-- Erreur attendue : PHONE_REQUIRED_UNLESS
-- ============================================================================
RETURN fn::validation_required_unless(
    NONE,
    "PHONE",
    false,
    false
);
