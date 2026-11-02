-- lyxal-test: assertions
-- Tests de fn::utils_cache_stats (format : crates/lyxal_core/implementation_plan.md §5).

-- test: statistiques
RETURN fn::utils_cache_stats([object::extend(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), { hits: 3 }), { key: "b", hits: 2, expires_at: d"2026-01-02T00:00:00Z" }], d"2026-01-01T12:00:00Z") == { total: 2, active: 1, expired: 1, total_hits: 5 };
