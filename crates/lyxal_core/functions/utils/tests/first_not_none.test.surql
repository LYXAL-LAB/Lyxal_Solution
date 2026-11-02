-- lyxal-test: assertions
-- Tests de fn::utils_first_not_none (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: NULL accepté
RETURN fn::utils_first_not_none([NONE, NULL, "a"]) == NULL;

-- test: aucune valeur
RETURN fn::utils_first_not_none([NONE]) == NONE;
