-- ============================================================================
-- TESTS — fn::sanitize_debug_export
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_debug_export({request_id:"r",schema_name:"user",started_at:time::now(),traces:[]},"json");
