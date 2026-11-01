-- lyxal-test: assertions
-- Tests de fn::sanitize_array_limit (format : crates/lyxal_core/implementation_plan.md §5).

-- test: tronqué
RETURN fn::sanitize_array_limit([1, 2, 3], 2) == [1, 2];

-- test: plus court que la limite
RETURN fn::sanitize_array_limit([1], 2) == [1];

-- test: limite nulle
RETURN fn::sanitize_array_limit([1, 2], 0) == [];

-- test: limite négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::sanitize_array_limit([1], -1);

-- test: entrée absente → NONE
RETURN fn::sanitize_array_limit(NONE, 2) == NONE;

-- test: NULL refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_limit(NULL, 2);

-- test: mauvais type refusé
-- attendu-erreur: CORE_SANITIZE_INVALID_TYPE
RETURN fn::sanitize_array_limit("a", 2);
