-- ============================================================================
-- TESTS — fn::validation_debug_field_traces
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================
RETURN fn::validation_debug_field_traces({traces:[{field:"name"},{field:"age"}]},"name");
