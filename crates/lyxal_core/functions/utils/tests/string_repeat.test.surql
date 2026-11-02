-- lyxal-test: assertions
-- Tests de fn::utils_string_repeat (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: avec séparateur
RETURN fn::utils_string_repeat("ab", 3, "-") == "ab-ab-ab";

-- test: zéro fois
RETURN fn::utils_string_repeat("ab", 0, "-") == "";

-- test: nombre négatif
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_string_repeat("a", -1, "");
