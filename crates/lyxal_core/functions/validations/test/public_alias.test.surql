-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/public_alias.test.surql
-- Fonction     : fn::validation_public_alias
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Alias valide
-- Résultat attendu : "Yaniss.BTP"
-- ============================================================================
RETURN fn::validation_public_alias(
    "Yaniss.BTP",
    "PUBLIC_ALIAS",
    3,
    50
);

-- ============================================================================
-- TEST 2 — Alias Unicode
-- Résultat attendu : "Équipe-Lyxal"
-- ============================================================================
RETURN fn::validation_public_alias(
    "Équipe-Lyxal",
    "PUBLIC_ALIAS",
    3,
    50
);

-- ============================================================================
-- TEST 3 — Espace interdit
-- Erreur attendue : PUBLIC_ALIAS_INVALID_PUBLIC_ALIAS
-- ============================================================================
RETURN fn::validation_public_alias(
    "Yaniss BTP",
    "PUBLIC_ALIAS",
    3,
    50
);
