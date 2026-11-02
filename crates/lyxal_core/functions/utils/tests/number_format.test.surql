-- lyxal-test: assertions
-- Tests de fn::utils_number_format (format : crates/lyxal_core/implementation_plan.md §5).

-- test: format français
RETURN fn::utils_number_format(1234567.891f, 2, ",", " ") == "1 234 567,89";

-- test: négatif
RETURN fn::utils_number_format(-1234.5f, 1, ".", ",") == "-1,234.5";

-- test: précision négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_number_format(1, -1, ".", ",");
