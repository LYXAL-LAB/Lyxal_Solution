-- ============================================================================
-- TESTS — fn::validation_unknown_keys_policy
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_unknown_keys_policy(
 {name:"Lyxal",extra:true},
 ["name"],
 "strip",
 "USER"
);
