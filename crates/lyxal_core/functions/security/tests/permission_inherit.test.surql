-- lyxal-test: assertions
-- Tests de fn::security_permission_inherit (format : crates/lyxal_core/implementation_plan.md §5).

-- test: héritage
RETURN fn::security_permission_inherit([{ resource: "booking", action: "read", effect: "allow", conditions: {} }], [{ resource: "booking", action: "write", effect: "allow", conditions: {} }, { resource: "booking", action: "read", effect: "allow", conditions: {} }]) == [{ resource: "booking", action: "read", effect: "allow", conditions: {} }, { resource: "booking", action: "write", effect: "allow", conditions: {} }];
