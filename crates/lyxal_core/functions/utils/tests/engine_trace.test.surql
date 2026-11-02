-- lyxal-test: assertions
-- Tests de fn::utils_engine_trace (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: trace
RETURN fn::utils_engine_trace("email", "Trim", " a ", "a", true, NONE, d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00.002Z") == { field: "email", rule: "trim", input: " a ", output: "a", ok: true, details: {}, started_at: d"2026-01-01T00:00:00Z", completed_at: d"2026-01-01T00:00:00.002Z", duration: 2ms };

-- test: fin avant début
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_trace("a", "r", 1, 1, true, NONE, d"2026-01-02T00:00:00Z", d"2026-01-01T00:00:00Z");
