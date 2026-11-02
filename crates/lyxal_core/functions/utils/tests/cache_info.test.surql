-- lyxal-test: assertions
-- Tests de fn::utils_cache_info (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: entrée active
RETURN fn::utils_cache_info(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T10:15:00Z").remaining == 45m;

-- test: entrée expirée
RETURN fn::utils_cache_info(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T12:00:00Z").expired AND fn::utils_cache_info(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T12:00:00Z").remaining == 0s;
