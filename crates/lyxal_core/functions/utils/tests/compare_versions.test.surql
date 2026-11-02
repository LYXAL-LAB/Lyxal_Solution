-- lyxal-test: assertions
-- Tests de fn::utils_compare_versions (format : crates/lyxal_core/implementation_plan.md §5).

-- test: version inférieure
RETURN fn::utils_compare_versions("v1.2.9", "1.10.0") == -1;

-- test: segments manquants
RETURN fn::utils_compare_versions("1.2", "1.2.0") == 0;

-- test: supérieure
RETURN fn::utils_compare_versions("2.0.0", "1.99.99") == 1;
