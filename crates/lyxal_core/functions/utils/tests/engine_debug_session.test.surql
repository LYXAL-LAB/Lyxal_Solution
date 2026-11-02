-- lyxal-test: assertions
-- Tests de fn::utils_engine_debug_session (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: session vide
RETURN fn::utils_engine_debug_session(" s1 ", d"2026-01-01T00:00:00Z") == { name: "s1", started_at: d"2026-01-01T00:00:00Z", traces: [] };

-- test: nom vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_engine_debug_session(" ", d"2026-01-01T00:00:00Z");
