-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/company_name.test.surql
-- Fonction     : fn::validation_company_name
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Société valide
-- Résultat attendu : "Lyxal SAS"
-- ============================================================================
RETURN fn::validation_company_name(
    "Lyxal SAS",
    "COMPANY_NAME",
    2,
    200
);

-- ============================================================================
-- TEST 2 — Ponctuation professionnelle
-- Résultat attendu : "Martin & Fils (BTP)"
-- ============================================================================
RETURN fn::validation_company_name(
    "Martin & Fils (BTP)",
    "COMPANY_NAME",
    2,
    200
);

-- ============================================================================
-- TEST 3 — Caractère de contrôle interdit
-- Erreur attendue : COMPANY_NAME_INVALID_COMPANY_NAME
-- ============================================================================
RETURN fn::validation_company_name(
    "Lyxal\nSAS",
    "COMPANY_NAME",
    2,
    200
);
