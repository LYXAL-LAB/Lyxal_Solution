-- lyxal-test: assertions
-- Tests de fn::utils_cache_touch (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: compteur et expiration
RETURN fn::utils_cache_touch(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T12:00:00Z", 2h).hits == 1 AND fn::utils_cache_touch(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T12:00:00Z", 2h).expires_at == d"2026-01-01T14:00:00Z";

-- test: expiration conservée sans durée
RETURN fn::utils_cache_touch(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), d"2026-01-01T12:00:00Z", NONE).expires_at == d"2026-01-01T11:00:00Z";
