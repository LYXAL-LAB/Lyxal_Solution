-- lyxal-test: assertions
-- Tests de fn::utils_number_percent (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: pourcentage arrondi
RETURN fn::utils_number_percent(1, 3, 2) == 33.33f;

-- test: entiers
RETURN fn::utils_number_percent(1, 4, 0) == 25f;

-- test: total nul
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_number_percent(1, 0, 2);
