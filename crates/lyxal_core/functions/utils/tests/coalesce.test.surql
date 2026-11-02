-- lyxal-test: assertions
-- Tests de fn::utils_coalesce (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: première valeur non NONE ni NULL
RETURN fn::utils_coalesce([NONE, NULL, "a", "b"]) == "a";

-- test: aucune valeur
RETURN fn::utils_coalesce([NONE, NULL]) == NONE;
