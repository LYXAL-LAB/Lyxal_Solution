-- lyxal-test: assertions
-- Tests de fn::utils_runtime_elapsed (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: unités
RETURN fn::utils_runtime_elapsed(d"2026-01-01T12:00:00Z", d"2026-01-01T12:00:01.5Z") == { duration: 1s500ms, seconds: 1, milliseconds: 1500, microseconds: 1500000 };

-- test: fin avant début
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::utils_runtime_elapsed(d"2026-01-01T12:00:00Z", d"2026-01-01T11:00:00Z");
