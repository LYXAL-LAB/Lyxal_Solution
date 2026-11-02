-- lyxal-test: assertions
-- Tests de fn::utils_array_chunk (format : crates/lyxal_core/implementation_plan.md §5).

-- test: paquets de 2
RETURN fn::utils_array_chunk([1, 2, 3, 4, 5], 2) == [[1, 2], [3, 4], [5]];

-- test: tableau vide
RETURN fn::utils_array_chunk([], 3) == [];

-- test: taille nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_array_chunk([1], 0);
