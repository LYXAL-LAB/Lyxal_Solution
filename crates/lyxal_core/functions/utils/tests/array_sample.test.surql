-- lyxal-test: assertions
-- Tests de fn::utils_array_sample (format : crates/lyxal_core/implementation_plan.md §5).

-- test: taille de l'échantillon
RETURN array::len(fn::utils_array_sample([1, 2, 3, 4], 2)) == 2;

-- test: éléments issus du tableau
RETURN array::all(fn::utils_array_sample([1, 2, 3], 3), |$v| $v IN [1, 2, 3]);

-- test: plus grand que le tableau
RETURN array::len(fn::utils_array_sample([1, 2], 5)) == 2;

-- test: nombre négatif
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_array_sample([1], -1);
