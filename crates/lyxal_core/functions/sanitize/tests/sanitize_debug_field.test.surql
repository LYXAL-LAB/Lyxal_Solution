-- ============================================================================
-- TESTS — fn::sanitize_debug_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_field({traces:[{field:"name"},{field:"age"}]},"name");
