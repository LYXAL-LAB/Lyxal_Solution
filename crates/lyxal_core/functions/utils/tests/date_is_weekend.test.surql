-- lyxal-test: assertions
-- Tests de fn::utils_date_is_weekend (format : crates/lyxal_core/implementation_plan.md §5).

-- test: samedi
RETURN fn::utils_date_is_weekend(d"2026-08-08T12:00:00Z");

-- test: lundi
RETURN !fn::utils_date_is_weekend(d"2026-08-03T12:00:00Z");
