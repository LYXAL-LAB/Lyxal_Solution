-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/validation_result.test.surql
-- Fonction     : fn::validation_result
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Résultat réussi
-- Résultat attendu : success = true
-- ============================================================================
RETURN fn::validation_result(
    true,
    "Lyxal",
    NONE,
    "NAME"
);

-- ============================================================================
-- TEST 2 — Résultat échoué
-- Résultat attendu : success = false
-- ============================================================================
RETURN fn::validation_result(
    false,
    NONE,
    "NAME_REQUIRED",
    "NAME"
);

-- ============================================================================
-- TEST 3 — Succès avec erreur
-- Erreur attendue : VALIDATION_SUCCESS_WITH_ERROR
-- ============================================================================
RETURN fn::validation_result(
    true,
    "Lyxal",
    "NAME_INVALID",
    "NAME"
);
