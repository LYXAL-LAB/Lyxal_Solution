-- lyxal-test: assertions
-- Tests de fn::utils_array_rotate (format : crates/lyxal_core/implementation_plan.md §5).

-- test: rotation à gauche
RETURN fn::utils_array_rotate([1, 2, 3, 4], 1) == [2, 3, 4, 1];

-- test: décalage négatif
RETURN fn::utils_array_rotate([1, 2, 3, 4], -1) == [4, 1, 2, 3];

-- test: tableau vide
RETURN fn::utils_array_rotate([], 3) == [];
