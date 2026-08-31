-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/surql_field_path.test.surql
-- Fonction     : fn::validation_surql_field_path
-- Domaine      : Core / Validation / SurrealQL
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Chemin imbriqué
-- Résultat attendu : "profile.address.city"
-- ============================================================================
RETURN fn::validation_surql_field_path(
    "profile.address.city",
    "FIELD_PATH",
    false,
    false,
    5
);

-- ============================================================================
-- TEST 2 — Wildcard de tableau
-- Résultat attendu : "addresses[*].city"
-- ============================================================================
RETURN fn::validation_surql_field_path(
    "addresses[*].city",
    "FIELD_PATH",
    true,
    false,
    5
);

-- ============================================================================
-- TEST 3 — Index numérique
-- Résultat attendu : "items[0].price"
-- ============================================================================
RETURN fn::validation_surql_field_path(
    "items[0].price",
    "FIELD_PATH",
    false,
    true,
    5
);

-- ============================================================================
-- TEST 4 — Wildcard interdit
-- Erreur attendue : FIELD_PATH_ARRAY_WILDCARD_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_surql_field_path(
    "addresses[*].city",
    "FIELD_PATH",
    false,
    false,
    5
);

-- ============================================================================
-- TEST 5 — Traversée de graphe interdite
-- Erreur attendue : FIELD_PATH_INVALID_FIELD_PATH
-- ============================================================================
RETURN fn::validation_surql_field_path(
    "user->orders",
    "FIELD_PATH",
    false,
    false,
    5
);
