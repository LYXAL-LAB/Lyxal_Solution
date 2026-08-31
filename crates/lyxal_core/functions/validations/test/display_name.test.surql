-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/display_name.test.surql
-- Fonction     : fn::validation_display_name
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nom d'affichage simple
-- Résultat attendu : "Yaniss D."
-- ============================================================================
RETURN fn::validation_display_name(
    "Yaniss D.",
    "DISPLAY_NAME",
    2,
    100,
    false
);

-- ============================================================================
-- TEST 2 — Emoji autorisé
-- Résultat attendu : "Yaniss 🚀"
-- ============================================================================
RETURN fn::validation_display_name(
    "Yaniss 🚀",
    "DISPLAY_NAME",
    2,
    100,
    true
);

-- ============================================================================
-- TEST 3 — Emoji interdit
-- Erreur attendue : DISPLAY_NAME_INVALID_DISPLAY_NAME
-- ============================================================================
RETURN fn::validation_display_name(
    "Yaniss 🚀",
    "DISPLAY_NAME",
    2,
    100,
    false
);
