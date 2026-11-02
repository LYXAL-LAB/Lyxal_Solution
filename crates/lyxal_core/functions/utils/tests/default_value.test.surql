-- lyxal-test: assertions
-- Tests de fn::utils_default_value (format : crates/lyxal_core/implementation_plan.md §5).

-- test: valeur présente
RETURN fn::utils_default_value("a", "z", true) == "a";

-- test: NONE remplacé
RETURN fn::utils_default_value(NONE, "z", false) == "z";

-- test: NULL remplacé si demandé
RETURN fn::utils_default_value(NULL, "z", true) == "z";

-- test: NULL conservé sinon
RETURN fn::utils_default_value(NULL, "z", false) == NULL;
