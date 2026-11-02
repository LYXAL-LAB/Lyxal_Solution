-- lyxal-test: assertions
-- Tests de fn::security_replay_window (format : crates/lyxal_core/implementation_plan.md §5).

-- test: dans la fenêtre
RETURN fn::security_replay_window(d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z", 5m) == { timestamp: d"2026-01-01T00:00:00Z", earliest: d"2025-12-31T23:55:00Z", latest: d"2026-01-01T00:05:00Z", valid: true };

-- test: fenêtre nulle
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_replay_window(d"2026-01-01T00:00:00Z", d"2026-01-01T00:00:00Z", 0s);
