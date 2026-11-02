-- lyxal-test: assertions
-- Tests de fn::utils_date_end_of_month (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: février
RETURN fn::utils_date_end_of_month(d"2026-02-10T00:00:00Z") == d"2026-02-28T23:59:59.999999999Z";

-- test: décembre
RETURN fn::utils_date_end_of_month(d"2026-12-10T00:00:00Z") == d"2026-12-31T23:59:59.999999999Z";
