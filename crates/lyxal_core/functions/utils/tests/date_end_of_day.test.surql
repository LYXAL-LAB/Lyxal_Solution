-- lyxal-test: assertions
-- Tests de fn::utils_date_end_of_day (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dernière nanoseconde
RETURN fn::utils_date_end_of_day(d"2026-01-01T15:30:00Z") == d"2026-01-01T23:59:59.999999999Z";
