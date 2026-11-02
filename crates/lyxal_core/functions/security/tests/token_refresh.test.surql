-- lyxal-test: assertions
-- Tests de fn::security_token_refresh (format : crates/lyxal_core/implementation_plan.md §5).

-- test: rotation
RETURN fn::security_token_refresh(u"0190b5a2-7c1e-7a3b-9f00-000000000001", u"0190b5a2-7c1e-7a3b-9f00-000000000002", d"2026-01-01T00:00:00Z", d"2026-01-01T00:05:00Z") == { old_token_id: u"0190b5a2-7c1e-7a3b-9f00-000000000001", new_token_id: u"0190b5a2-7c1e-7a3b-9f00-000000000002", rotated_at: d"2026-01-01T00:00:00Z", old_valid_until: d"2026-01-01T00:05:00Z", status: "rotated" };

-- test: fenêtre inversée
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::security_token_refresh(u"0190b5a2-7c1e-7a3b-9f00-000000000001", u"0190b5a2-7c1e-7a3b-9f00-000000000002", d"2026-01-01T00:00:00Z", d"2025-12-31T00:00:00Z");
