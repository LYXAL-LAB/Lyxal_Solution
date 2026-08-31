-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/exactly_one.test.surql
-- Fonction     : fn::validation_exactly_one
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Exactement une valeur
-- Résultat attendu : tableau reçu
-- ============================================================================
RETURN fn::validation_exactly_one(
    [user:one, NONE, NONE],
    "OWNER"
);

-- ============================================================================
-- TEST 2 — Aucune valeur
-- Erreur attendue : OWNER_EXACTLY_ONE_REQUIRED
-- ============================================================================
RETURN fn::validation_exactly_one(
    [NONE, NONE, NONE],
    "OWNER"
);

-- ============================================================================
-- TEST 3 — Plusieurs valeurs
-- Erreur attendue : OWNER_EXACTLY_ONE_REQUIRED
-- ============================================================================
RETURN fn::validation_exactly_one(
    [user:one, team:one, NONE],
    "OWNER"
);
