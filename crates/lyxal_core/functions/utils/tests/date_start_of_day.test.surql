-- lyxal-test: assertions
-- Tests de fn::utils_date_start_of_day (format : crates/lyxal_core/implementation_plan.md §5).

-- test: minuit
RETURN fn::utils_date_start_of_day(d"2026-01-01T15:30:00Z") == d"2026-01-01T00:00:00Z";
