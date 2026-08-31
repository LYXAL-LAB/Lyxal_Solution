-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/tuple_length.test.surql
-- Fonction     : fn::validation_tuple_length
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tuple de deux éléments
-- Résultat attendu : [2.3522, 48.8566]
-- ============================================================================
RETURN fn::validation_tuple_length(
    [2.3522, 48.8566],
    "COORDINATES",
    2
);

-- ============================================================================
-- TEST 2 — Tuple vide
-- Résultat attendu : []
-- ============================================================================
RETURN fn::validation_tuple_length([], "EMPTY_TUPLE", 0);

-- ============================================================================
-- TEST 3 — Longueur incorrecte
-- Erreur attendue : COORDINATES_INVALID_TUPLE_LENGTH
-- ============================================================================
RETURN fn::validation_tuple_length(
    [2.3522],
    "COORDINATES",
    2
);

-- ============================================================================
-- TEST 4 — Objet refusé
-- Erreur attendue : COORDINATES_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_tuple_length(
    { x: 2.3522, y: 48.8566 },
    "COORDINATES",
    2
);
