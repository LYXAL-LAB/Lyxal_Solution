-- ============================================================================
-- TESTS — fn::security_sdk_permission
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_sdk_permission(
    [{resource:"a",action:"read",effect:"allow"}],
    "a",
    "read",
    NONE
);
