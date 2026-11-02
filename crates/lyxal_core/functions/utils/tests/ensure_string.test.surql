-- lyxal-test: assertions
-- Tests de fn::utils_ensure_string (format : crates/lyxal_core/implementation_plan.md §5).

-- test: nombre converti
RETURN fn::utils_ensure_string(12, "x") == "12";

-- test: NONE remplacé
RETURN fn::utils_ensure_string(NONE, "x") == "x";

-- test: NULL remplacé
RETURN fn::utils_ensure_string(NULL, "x") == "x";
