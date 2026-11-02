-- lyxal-test: assertions
-- Tests de fn::utils_is_blank (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: chaîne blanche
RETURN fn::utils_is_blank("  ");

-- test: NONE
RETURN fn::utils_is_blank(NONE);

-- test: zéro n'est pas blanc
RETURN !fn::utils_is_blank(0);
