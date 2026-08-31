-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object_no_null.test.surql
-- Fonction     : fn::validation_object_no_null
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Objet sans NULL
-- Résultat attendu : objet reçu
-- ============================================================================
RETURN fn::validation_object_no_null(
    { name: "Lyxal", enabled: true },
    "CONFIG"
);

-- ============================================================================
-- TEST 2 — Valeur NULL
-- Erreur attendue : CONFIG_NULL_VALUE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_object_no_null(
    { name: "Lyxal", description: NULL },
    "CONFIG"
);

-- ============================================================================
-- TEST 3 — Valeur NONE autorisée par cette fonction
-- Résultat attendu : objet reçu
-- ============================================================================
RETURN fn::validation_object_no_null(
    { name: "Lyxal", description: NONE },
    "CONFIG"
);

-- ============================================================================
-- TEST 4 — Objet racine NULL
-- Erreur attendue : CONFIG_NULL_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_object_no_null(NULL, "CONFIG");
