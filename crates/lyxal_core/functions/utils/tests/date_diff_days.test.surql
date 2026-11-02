-- lyxal-test: assertions
-- Tests de fn::utils_date_diff_days (format : crates/lyxal_core/implementation_plan.md §5).

-- test: jours fractionnaires
RETURN fn::utils_date_diff_days(d"2026-01-01T00:00:00Z", d"2026-01-02T12:00:00Z") == 1.5dec;
