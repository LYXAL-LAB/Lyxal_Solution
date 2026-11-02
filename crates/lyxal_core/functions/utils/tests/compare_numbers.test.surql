-- lyxal-test: assertions
-- Tests de fn::utils_compare_numbers (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: dans la tolérance
RETURN fn::utils_compare_numbers(1.0f, 1.05f, 0.1f) == 0;

-- test: supérieur
RETURN fn::utils_compare_numbers(3, 2, 0) == 1;

-- test: tolérance négative
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_compare_numbers(1, 2, -1);
