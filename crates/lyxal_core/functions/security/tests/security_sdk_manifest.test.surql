-- ============================================================================
-- TESTS — fn::security_sdk_manifest
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_sdk_manifest({
    entries:[
        {name:"req",version:"v1",status:"active"}
    ]
});
