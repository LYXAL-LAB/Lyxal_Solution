-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/tuple_types.test.surql
-- Fonction     : fn::validation_tuple_types
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tuple string/int valide
-- Résultat attendu : ["page", 10]
-- ============================================================================
RETURN fn::validation_tuple_types(
    ["page", 10],
    "PAGINATION",
    ["string", "int"]
);

-- ============================================================================
-- TEST 2 — Tuple int/string invalide
-- Erreur attendue : PAGINATION_INVALID_TUPLE_ITEM_TYPE
-- ============================================================================
RETURN fn::validation_tuple_types(
    [10, "page"],
    "PAGINATION",
    ["string", "int"]
);

-- ============================================================================
-- TEST 3 — Longueur incorrecte
-- Erreur attendue : PAGINATION_INVALID_TUPLE_LENGTH
-- ============================================================================
RETURN fn::validation_tuple_types(
    ["page"],
    "PAGINATION",
    ["string", "int"]
);

-- ============================================================================
-- TEST 4 — Types attendus vides
-- Erreur attendue : VALIDATION_EMPTY_TUPLE_TYPES
-- ============================================================================
RETURN fn::validation_tuple_types(
    [],
    "PAGINATION",
    []
);
