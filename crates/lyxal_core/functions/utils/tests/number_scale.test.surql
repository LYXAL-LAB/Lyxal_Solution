-- lyxal-test: assertions
-- Tests de fn::utils_number_scale (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: changement d'échelle
RETURN fn::utils_number_scale(5, 0, 10, 0, 100) == 50;

-- test: intervalle source nul
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_number_scale(5, 1, 1, 0, 10);
