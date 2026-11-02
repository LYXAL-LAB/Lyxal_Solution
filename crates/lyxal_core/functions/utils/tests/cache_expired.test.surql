-- lyxal-test: assertions
-- Tests de fn::utils_cache_expired (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: expirée
RETURN fn::utils_cache_expired(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T12:00:00Z");

-- test: active
RETURN !fn::utils_cache_expired(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T10:30:00Z");
