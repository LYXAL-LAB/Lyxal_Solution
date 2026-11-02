-- lyxal-test: assertions
-- Tests de fn::utils_is_empty (format : crates/lyxal_core/implementation_plan.md §5).

-- test: tableau vide
RETURN fn::utils_is_empty([]);

-- test: objet vide
RETURN fn::utils_is_empty({});

-- test: espace non vide
RETURN !fn::utils_is_empty(" ");
