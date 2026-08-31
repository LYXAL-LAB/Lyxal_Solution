-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object_non_empty.test.surql
-- Fonction     : fn::validation_object_non_empty
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Objet non vide
-- Résultat attendu : { enabled: true }
-- ============================================================================
RETURN fn::validation_object_non_empty(
    { enabled: true }, "CONFIG"
);

-- ============================================================================
-- TEST 2 — Objet vide
-- Erreur attendue : CONFIG_EMPTY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_object_non_empty({}, "CONFIG");

-- ============================================================================
-- TEST 3 — Chaîne refusée
-- Erreur attendue : CONFIG_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_object_non_empty("{}", "CONFIG");
