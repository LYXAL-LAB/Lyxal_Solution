-- ============================================================================
-- TESTS — fn::security_permission_inherit
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_permission_inherit(
    [{resource:"a",action:"read",effect:"allow"}],
    [{resource:"a",action:"write",effect:"allow"}]
);
