-- ============================================================================
-- TESTS — fn::sanitize_sdk_manifest
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_sdk_manifest({entries:[{name:"user",version:"v1",status:"active"}]});
