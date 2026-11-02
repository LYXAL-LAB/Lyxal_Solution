-- lyxal-test: assertions
-- Tests de fn::utils_first_not_none (format : crates/lyxal_core/implementation_plan.md §5).

-- test: NULL accepté
RETURN fn::utils_first_not_none([NONE, NULL, "a"]) == NULL;

-- test: aucune valeur
RETURN fn::utils_first_not_none([NONE]) == NONE;
