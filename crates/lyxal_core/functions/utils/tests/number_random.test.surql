-- lyxal-test: assertions
-- Tests de fn::utils_number_random (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: dans l'intervalle
RETURN fn::utils_number_random(1, 6) IN [1, 2, 3, 4, 5, 6];

-- test: intervalle réduit
RETURN fn::utils_number_random(4, 4) == 4;

-- test: bornes inversées
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_number_random(6, 1);
