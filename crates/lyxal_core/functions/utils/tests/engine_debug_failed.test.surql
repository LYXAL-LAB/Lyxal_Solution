-- lyxal-test: assertions
-- Tests de fn::utils_engine_debug_failed (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: échecs seulement
RETURN fn::utils_engine_debug_failed([fn::utils_engine_trace("email", "Trim", " a ", "a", true, NONE, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.002Z"), fn::utils_engine_trace("age", "min", 1, 1, false, { code: "CORE_VALIDATION_TOO_SMALL" }, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.005Z")]).map(|$x| $x.field) == ["age"];
