-- ============================================================================
-- TESTS — fn::sanitize_runtime_validate
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_validate(
 {
  name:"user",
  version:"v1",
  fields:{name:{pipeline:[{rule:"trim"},{rule:"lowercase"}]}},
  unknown_keys_policy:"strip"
 },
 {name:" LYXAL ",extra:true},
 10,
 "req-001"
);
