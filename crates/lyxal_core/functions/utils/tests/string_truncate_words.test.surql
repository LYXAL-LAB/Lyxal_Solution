-- lyxal-test: assertions
-- Tests de fn::utils_string_truncate_words (format : crates/lyxal_core/implementation_plan.md §5).

-- test: tronquée
RETURN fn::utils_string_truncate_words("un deux  trois quatre", 2, "…") == "un deux…";

-- test: assez courte
RETURN fn::utils_string_truncate_words(" un deux ", 5, "…") == "un deux";

-- test: maximum négatif
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_string_truncate_words("a", -1, "");
