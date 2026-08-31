-- ============================================================================
-- TESTS — fn::sanitize_sdk_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_sdk_request({name:"user",version:"v1",fields:{}},{},NONE);
