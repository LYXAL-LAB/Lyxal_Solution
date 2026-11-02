-- lyxal-test: assertions
-- Tests de fn::utils_date_age (format : crates/lyxal_core/implementation_plan.md §5).

-- test: anniversaire passé
RETURN fn::utils_date_age(d"1990-06-15T00:00:00Z", d"2026-06-15T00:00:00Z") == 36;

-- test: anniversaire à venir
RETURN fn::utils_date_age(d"1990-06-15T00:00:00Z", d"2026-06-14T00:00:00Z") == 35;
