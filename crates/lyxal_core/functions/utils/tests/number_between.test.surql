-- lyxal-test: assertions
-- Tests de fn::utils_number_between (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: inclusif
RETURN fn::utils_number_between(10, 0, 10, true);

-- test: exclusif
RETURN !fn::utils_number_between(10, 0, 10, false);

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_number_between(1, 10, 0, true);
