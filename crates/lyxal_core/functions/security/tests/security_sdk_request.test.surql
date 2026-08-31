-- ============================================================================
-- TESTS — fn::security_sdk_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_sdk_request(
    {name:"req",version:"v1",fields:{}},
    {},
    NONE
);
