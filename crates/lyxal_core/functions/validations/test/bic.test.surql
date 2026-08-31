-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/bic.test.surql
-- Fonction     : fn::validation_bic
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — BIC à 8 caractères
RETURN fn::validation_bic("bnpafrpp", "BIC", ["FR"]);

-- TEST 2 — BIC avec branche
RETURN fn::validation_bic("SOGEFRPPXXX", "BIC", NONE);

-- TEST 3 — Forme invalide
-- Erreur attendue : BIC_INVALID_BIC
RETURN fn::validation_bic("BNPAFR", "BIC", NONE);

-- TEST 4 — Pays interdit
-- Erreur attendue : BIC_BIC_COUNTRY_NOT_ALLOWED
RETURN fn::validation_bic("DEUTDEFF", "BIC", ["FR"]);
