-- lyxal-test: assertions
-- Tests de fn::utils_number_scale (format : crates/lyxal_core/implementation_plan.md §5).

-- test: changement d'échelle
RETURN fn::utils_number_scale(5, 0, 10, 0, 100) == 50;

-- test: intervalle source nul
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_number_scale(5, 1, 1, 0, 10);
