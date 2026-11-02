-- lyxal-test: assertions
-- Tests de fn::utils_cache_merge (format : crates/lyxal_core/implementation_plan.md §5).

-- test: remplacement par clé
RETURN fn::utils_cache_merge([{ key: "a", v: 1, expires_at: d"2026-01-02T00:00:00Z" }, { key: "b", v: 1, expires_at: d"2026-01-02T00:00:00Z" }], { key: "a", v: 2, expires_at: d"2026-01-02T00:00:00Z" }, d"2026-01-01T12:00:00Z").map(|$e| $e.key + <string> $e.v) == ["b1", "a2"];
