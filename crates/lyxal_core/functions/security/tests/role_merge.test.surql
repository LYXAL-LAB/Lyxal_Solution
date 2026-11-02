-- lyxal-test: assertions
-- Tests de fn::security_role_merge (format : crates/lyxal_core/implementation_plan.md §5).

-- test: fusion
RETURN fn::security_role_merge({ name: "a", permissions: [{ resource: "booking", action: "read", effect: "allow", conditions: {} }], inherits: ["x"], enabled: true }, { permissions: [{ resource: "booking", action: "write", effect: "allow", conditions: {} }], inherits: ["y"], enabled: false }) == { name: "a", permissions: [{ resource: "booking", action: "read", effect: "allow", conditions: {} }, { resource: "booking", action: "write", effect: "allow", conditions: {} }], inherits: ["x", "y"], enabled: false };
