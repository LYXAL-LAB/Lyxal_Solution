-- lyxal-test: assertions
-- Tests de fn::utils_collection_window (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fenêtres glissantes
RETURN fn::utils_collection_window([1, 2, 3, 4], 2, 1) == [[1, 2], [2, 3], [3, 4]];

-- test: plus court que la fenêtre
RETURN fn::utils_collection_window([1], 2, 1) == [];

-- test: pas nul
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_collection_window([1, 2], 1, 0);
