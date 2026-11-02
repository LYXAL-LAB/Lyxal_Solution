-- lyxal-test: assertions
-- Tests de fn::utils_engine_debug_slowest (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: plus lentes d'abord
RETURN fn::utils_engine_debug_slowest([fn::utils_engine_trace("email", "Trim", " a ", "a", true, NONE, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.002Z"), fn::utils_engine_trace("age", "min", 1, 1, false, { code: "CORE_VALIDATION_TOO_SMALL" }, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.005Z")], 1).map(|$x| $x.field) == ["age"];

-- test: limite supérieure au nombre
RETURN array::len(fn::utils_engine_debug_slowest([fn::utils_engine_trace("email", "Trim", " a ", "a", true, NONE, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.002Z")], 5)) == 1;

-- test: limite nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_debug_slowest([fn::utils_engine_trace("email", "Trim", " a ", "a", true, NONE, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.002Z")], 0);
