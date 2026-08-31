-- ============================================================================
-- TESTS — fn::security_debug_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_pipeline(
    "request",
    [{rule:"detect_payload"}],
    {findings:[{detected:true}],decisions:[],value:"x"}
);
