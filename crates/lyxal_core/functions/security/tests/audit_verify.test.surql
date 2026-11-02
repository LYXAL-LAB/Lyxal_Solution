-- lyxal-test: assertions
-- Tests de fn::security_audit_verify (format : crates/lyxal_core/implementation_plan.md §5).

-- test: chaîne intacte
RETURN fn::security_audit_verify(fn::security_audit_chain([{ a: 1 }, { a: 2 }])).valid;

-- test: altération détectée
RETURN !fn::security_audit_verify([fn::security_audit_chain([{ a: 1 }, { a: 2 }])[0], object::extend(fn::security_audit_chain([{ a: 1 }, { a: 2 }])[1], { event: { a: 3 } })]).valid;
