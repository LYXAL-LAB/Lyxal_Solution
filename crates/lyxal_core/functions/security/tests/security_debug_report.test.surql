-- ============================================================================
-- TESTS — fn::security_debug_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_report({
    request_id:"r",
    schema_name:"req",
    started_at:time::now(),
    traces:[{
        field:"payload",
        rule:"detect_payload",
        finding:{detected:true},
        decision:NONE,
        duration:1ms
    }]
});
