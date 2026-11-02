-- lyxal-test: assertions
-- Tests de fn::utils_date_start_of_month (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: premier du mois
RETURN fn::utils_date_start_of_month(d"2026-02-17T15:30:00Z") == d"2026-02-01T00:00:00Z";
