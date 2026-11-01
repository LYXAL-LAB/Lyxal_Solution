-- ============================================================================
-- TESTS — fn::validation_runtime_context
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_runtime_context("user::profile","v1","fail_fast",{});
RETURN fn::validation_runtime_context("user","v1","async",NONE);
