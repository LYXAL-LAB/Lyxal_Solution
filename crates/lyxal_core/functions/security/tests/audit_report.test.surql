-- lyxal-test: assertions
-- Tests de fn::security_audit_report (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: rapport
RETURN fn::security_audit_report(fn::security_audit_chain([{ occurred_at: d"2026-01-01T00:00:00Z" }, { occurred_at: d"2026-01-02T00:00:00Z" }])).last_event_at == d"2026-01-02T00:00:00Z";

-- test: chaîne vide
RETURN fn::security_audit_report([]).entry_count == 0 AND fn::security_audit_report([]).first_event_at IS NONE;
