-- ============================================================================
-- TESTS — fn::security_debug_summary
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_summary({
    request_id:"r",
    schema_name:"req",
    started_at:time::now(),
    traces:[
        {finding:{detected:true},decision:NONE}
    ]
});
