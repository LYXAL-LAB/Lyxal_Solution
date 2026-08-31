-- ============================================================================
-- TESTS — fn::sanitize_runtime_execute_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_execute_object(
 {
  fields:{name:{default:NONE}},
  compiled_fields:{name:{field:"NAME",steps:[{rule:"trim"}]}},
  unknown_keys_policy:"strip"
 },
 {name:" Lyxal ",extra:true},
 10
);
