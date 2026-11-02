-- lyxal-test: assertions
-- Tests de fn::security_permission_check (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: autorisation
RETURN fn::security_permission_check([{ resource: "booking", action: "read", effect: "allow", conditions: {} }], "BOOKING", "read", NONE).allowed;

-- test: refus explicite prioritaire
RETURN fn::security_permission_check([{ resource: "booking", action: "read", effect: "allow", conditions: {} }, { resource: "booking", action: "read", effect: "deny", conditions: {} }], "booking", "read", NONE).explicit_deny;

-- test: aucune permission correspondante
RETURN !fn::security_permission_check([{ resource: "booking", action: "write", effect: "allow", conditions: {} }], "booking", "read", NONE).allowed;
