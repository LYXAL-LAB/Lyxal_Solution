-- ============================================================================
-- TESTS — fn::security_debug_export
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_export({
    request_id:"r",
    schema_name:"req",
    started_at:time::now(),
    traces:[]
},"json");
