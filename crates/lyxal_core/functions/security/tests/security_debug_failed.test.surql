-- ============================================================================
-- TESTS — fn::security_debug_failed
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_failed({
    traces:[
        {finding:{detected:true},decision:NONE},
        {finding:NONE,decision:{allowed:true}}
    ]
});
