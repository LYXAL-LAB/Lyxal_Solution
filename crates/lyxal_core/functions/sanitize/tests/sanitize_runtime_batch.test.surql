-- ============================================================================
-- TESTS — fn::sanitize_runtime_batch
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_runtime_batch(
 {
  fields:{name:{}},
  compiled_fields:{name:{field:"NAME",steps:[{rule:"trim"}]}},
  unknown_keys_policy:"strip"
 },
 [{name:" A "},{name:" B "}],
 10
);
