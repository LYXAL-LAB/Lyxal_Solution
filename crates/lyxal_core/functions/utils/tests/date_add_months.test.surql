-- lyxal-test: assertions
-- Tests de fn::utils_date_add_months (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fin de mois ramenée
RETURN fn::utils_date_add_months(d"2026-01-31T08:00:00Z", 1) == d"2026-02-28T08:00:00Z";

-- test: année bissextile
RETURN fn::utils_date_add_months(d"2028-01-31T00:00:00Z", 1) == d"2028-02-29T00:00:00Z";

-- test: mois négatif
RETURN fn::utils_date_add_months(d"2026-03-15T00:00:00Z", -3) == d"2025-12-15T00:00:00Z";
