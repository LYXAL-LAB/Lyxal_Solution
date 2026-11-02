-- lyxal-test: assertions
-- Tests de fn::utils_compare_versions (format : crates/lyxal_core/implementation_plan.md §5).

-- test: version inférieure
RETURN fn::utils_compare_versions("v1.2.9", "1.10.0") == -1;

-- test: segments manquants
RETURN fn::utils_compare_versions("1.2", "1.2.0") == 0;

-- test: supérieure
RETURN fn::utils_compare_versions("2.0.0", "1.99.99") == 1;

-- test: segment non numérique
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_compare_versions("1.0.0-beta", "1.0.0");

-- test: version vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_compare_versions("1.0", " ");

-- test: segment trop long
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_compare_versions("1.99999999999999999999", "1.0");
