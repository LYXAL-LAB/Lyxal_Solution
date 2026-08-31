-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/ape_naf_code.test.surql
-- Fonction     : fn::validation_ape_naf_code
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Code valide
RETURN fn::validation_ape_naf_code("4120a", "APE_CODE");

-- TEST 2 — Espace supprimé
RETURN fn::validation_ape_naf_code("6201 z", "APE_CODE");

-- TEST 3 — Lettre manquante
-- Erreur attendue : APE_CODE_INVALID_APE_NAF_CODE
RETURN fn::validation_ape_naf_code("4120", "APE_CODE");
