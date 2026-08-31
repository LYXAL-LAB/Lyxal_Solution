-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/required_if.test.surql
-- Fonction     : fn::validation_required_if
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Condition fausse
-- Résultat attendu : NONE
-- ============================================================================
RETURN fn::validation_required_if(
    NONE,
    "COMPANY_NAME",
    false,
    false
);

-- ============================================================================
-- TEST 2 — Condition vraie et valeur présente
-- Résultat attendu : "Lyxal"
-- ============================================================================
RETURN fn::validation_required_if(
    "Lyxal",
    "COMPANY_NAME",
    true,
    false
);

-- ============================================================================
-- TEST 3 — Condition vraie et valeur absente
-- Erreur attendue : COMPANY_NAME_REQUIRED_IF
-- ============================================================================
RETURN fn::validation_required_if(
    NONE,
    "COMPANY_NAME",
    true,
    false
);
