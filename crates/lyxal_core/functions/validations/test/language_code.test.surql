-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/language_code.test.surql
-- Fonction     : fn::validation_language_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Français
-- Résultat attendu : "fr"
-- ============================================================================
RETURN fn::validation_language_code(
    "FR",
    "LANGUAGE",
    false,
    NONE
);

-- ============================================================================
-- TEST 2 — Code alpha-3 autorisé
-- Résultat attendu : "fra"
-- ============================================================================
RETURN fn::validation_language_code(
    "FRA",
    "LANGUAGE",
    true,
    NONE
);

-- ============================================================================
-- TEST 3 — Alpha-3 interdit
-- Erreur attendue : LANGUAGE_INVALID_LANGUAGE_CODE
-- ============================================================================
RETURN fn::validation_language_code(
    "fra",
    "LANGUAGE",
    false,
    NONE
);

-- ============================================================================
-- TEST 4 — Langue non autorisée
-- Erreur attendue : LANGUAGE_LANGUAGE_CODE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_language_code(
    "de",
    "LANGUAGE",
    false,
    ["fr", "en"]
);
