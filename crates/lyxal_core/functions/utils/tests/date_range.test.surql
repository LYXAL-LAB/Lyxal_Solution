-- lyxal-test: assertions
-- Tests de fn::utils_date_range (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: fin exclue
RETURN fn::utils_date_range(d"2026-01-01T00:00:00Z", d"2026-01-03T00:00:00Z", 1d, false) == [d"2026-01-01T00:00:00Z", d"2026-01-02T00:00:00Z"];

-- test: fin incluse sur le pas
RETURN fn::utils_date_range(d"2026-01-01T00:00:00Z", d"2026-01-03T00:00:00Z", 1d, true) == [d"2026-01-01T00:00:00Z", d"2026-01-02T00:00:00Z", d"2026-01-03T00:00:00Z"];

-- test: fin incluse hors pas
RETURN fn::utils_date_range(d"2026-01-01T00:00:00Z", d"2026-01-01T05:00:00Z", 2h, true) == [d"2026-01-01T00:00:00Z", d"2026-01-01T02:00:00Z", d"2026-01-01T04:00:00Z", d"2026-01-01T05:00:00Z"];

-- test: pas nul
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_date_range(d"2026-01-01T00:00:00Z", d"2026-01-02T00:00:00Z", 0s, false);

-- test: fin avant début
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_date_range(d"2026-01-02T00:00:00Z", d"2026-01-01T00:00:00Z", 1d, false);
