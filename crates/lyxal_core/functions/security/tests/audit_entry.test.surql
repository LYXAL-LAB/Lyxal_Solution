-- lyxal-test: assertions
-- Tests de fn::security_audit_entry (format : crates/lyxal_core/implementation_plan.md §5).

-- test: empreinte chaînée
RETURN fn::security_audit_entry({ a: 1 }, "h0").entry_hash == crypto::sha256("h0:" + <string> { a: 1 });

-- test: types conservés
RETURN fn::security_audit_entry({ a: 1s }, NONE).entry_hash != fn::security_audit_entry({ a: "1s" }, NONE).entry_hash;
