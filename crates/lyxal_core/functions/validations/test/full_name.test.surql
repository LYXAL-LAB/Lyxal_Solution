-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/full_name.test.surql
-- Fonction     : fn::validation_full_name
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nom complet valide
-- Résultat attendu : "Yaniss Dubreucq"
-- ============================================================================
RETURN fn::validation_full_name(
    "Yaniss Dubreucq",
    "FULL_NAME",
    2,
    6,
    200
);

-- ============================================================================
-- TEST 2 — Nom composé valide
-- Résultat attendu : "Jean-Pierre Le Gall"
-- ============================================================================
RETURN fn::validation_full_name(
    "Jean-Pierre Le Gall",
    "FULL_NAME",
    2,
    6,
    200
);

-- ============================================================================
-- TEST 3 — Pas assez de mots
-- Erreur attendue : FULL_NAME_TOO_FEW_WORDS
-- ============================================================================
RETURN fn::validation_full_name(
    "Yaniss",
    "FULL_NAME",
    2,
    6,
    200
);
