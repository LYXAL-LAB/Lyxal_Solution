-- lyxal-test: assertions
-- Tests de fn::utils_cache_hash (format : crates/lyxal_core/implementation_plan.md §5).

-- test: empreinte SHA-256 stable
RETURN string::len(fn::utils_cache_hash(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE))) == 64 AND fn::utils_cache_hash(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE)) == fn::utils_cache_hash(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE));

-- test: dépend de la valeur
RETURN fn::utils_cache_hash(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE)) != fn::utils_cache_hash(object::extend(fn::utils_cache_entry(" k ", 42, 1h, d"2026-01-01T10:00:00Z", NONE), { value: 43 }));
