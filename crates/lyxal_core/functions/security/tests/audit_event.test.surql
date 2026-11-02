-- lyxal-test: assertions
-- Tests de fn::security_audit_event (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: événement normalisé
RETURN fn::security_audit_event("login", "u1", "account:1", "Login", "success", NONE, d"2026-01-01T00:00:00Z").action == 'login' AND fn::security_audit_event("login", "u1", "account:1", "Login", "success", NONE, d"2026-01-01T00:00:00Z").outcome == 'success' AND fn::security_audit_event("login", "u1", "account:1", "Login", "success", NONE, d"2026-01-01T00:00:00Z").metadata == {};

-- test: issue inconnue
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::security_audit_event("login", NONE, "s", "a", "maybe", NONE, d"2026-01-01T00:00:00Z");
