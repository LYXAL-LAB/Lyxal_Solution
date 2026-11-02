-- lyxal-test: assertions
-- Tests de fn::security_audit_chain (format : crates/lyxal_core/implementation_plan.md §5).

-- test: chaînage
RETURN fn::security_audit_chain([{ a: 1 }, { a: 2 }])[1].previous_hash == fn::security_audit_chain([{ a: 1 }, { a: 2 }])[0].entry_hash;

-- test: chaîne vide
RETURN fn::security_audit_chain([]) == [];
