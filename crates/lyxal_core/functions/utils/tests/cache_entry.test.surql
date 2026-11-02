-- lyxal-test: assertions
-- Tests de fn::utils_cache_entry (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: entrée construite
RETURN fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE) == { key: "k", value: 42, created_at: d"2026-01-01T10:00:00Z", updated_at: d"2026-01-01T10:00:00Z", expires_at: d"2026-01-01T11:00:00Z", hits: 0, metadata: {} };

-- test: durée nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_cache_entry("k", 1, 0s, d"2026-01-01T12:00:00Z", NONE);
