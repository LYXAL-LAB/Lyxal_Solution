-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object_no_none.test.surql
-- Fonction     : fn::validation_object_no_none
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Objet sans NONE
-- Résultat attendu : objet reçu
-- ============================================================================
RETURN fn::validation_object_no_none(
    { name: "Lyxal", enabled: true },
    "CONFIG"
);

-- ============================================================================
-- TEST 2 — Valeur NONE
-- Erreur attendue : CONFIG_NONE_VALUE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_object_no_none(
    { name: "Lyxal", description: NONE },
    "CONFIG"
);

-- ============================================================================
-- TEST 3 — NULL n'est pas NONE
-- Résultat attendu : objet reçu
-- ============================================================================
RETURN fn::validation_object_no_none(
    { name: "Lyxal", description: NULL },
    "CONFIG"
);

-- ============================================================================
-- TEST 4 — Tableau refusé
-- Erreur attendue : CONFIG_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_object_no_none(
    [{ name: "Lyxal" }],
    "CONFIG"
);
