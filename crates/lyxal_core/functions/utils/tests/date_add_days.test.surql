-- lyxal-test: assertions
-- Tests de fn::utils_date_add_days (format : crates/lyxal_core/implementation_plan.md §5).

-- test: ajout de jours
RETURN fn::utils_date_add_days(d"2026-01-30T10:00:00Z", 3) == d"2026-02-02T10:00:00Z";

-- test: retrait de jours
RETURN fn::utils_date_add_days(d"2026-01-01T00:00:00Z", -1) == d"2025-12-31T00:00:00Z";
