-- lyxal-test: assertions
-- Tests de fn::utils_coalesce (format : crates/lyxal_core/implementation_plan.md §5).

-- test: première valeur non NONE ni NULL
RETURN fn::utils_coalesce([NONE, NULL, "a", "b"]) == "a";

-- test: aucune valeur
RETURN fn::utils_coalesce([NONE, NULL]) == NONE;
