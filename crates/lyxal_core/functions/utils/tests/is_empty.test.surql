-- lyxal-test: assertions
-- Tests de fn::utils_is_empty (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: tableau vide
RETURN fn::utils_is_empty([]);

-- test: objet vide
RETURN fn::utils_is_empty({});

-- test: espace non vide
RETURN !fn::utils_is_empty(" ");
