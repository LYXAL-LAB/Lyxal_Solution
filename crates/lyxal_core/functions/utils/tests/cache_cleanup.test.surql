-- lyxal-test: assertions
-- Tests de fn::utils_cache_cleanup (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: entrées expirées retirées
RETURN fn::utils_cache_cleanup([fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), { key: "b", expires_at: d"2026-01-02T00:00:00Z" }], d"2026-01-01T12:00:00Z").map(|$e| $e.key) == ["b"];
