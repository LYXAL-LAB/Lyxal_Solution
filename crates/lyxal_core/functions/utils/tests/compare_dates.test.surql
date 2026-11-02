-- lyxal-test: assertions
-- Tests de fn::utils_compare_dates (format : crates/lyxal_core/implementation_plan.md §5).

-- test: antérieure
RETURN fn::utils_compare_dates(d"2026-01-01T00:00:00Z", d"2026-01-02T00:00:00Z") == -1;

-- test: égales
RETURN fn::utils_compare_dates(d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z") == 0;
