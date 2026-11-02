-- lyxal-test: assertions
-- Tests de fn::utils_runtime_info (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: durée de fonctionnement
RETURN fn::utils_runtime_info({}, {}, {}, d"2026-01-01T00:00:00Z").uptime > 0s;

-- test: champs transmis
RETURN fn::utils_runtime_info({ v: 1 }, {}, {}, d"2026-01-01T12:00:00Z").version == { v: 1 };
