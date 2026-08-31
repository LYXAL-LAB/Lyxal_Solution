-- ============================================================================
-- TESTS — fn::security_permission_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_permission_merge(
    [{resource:"a",action:"read",effect:"allow"}],
    [{resource:"a",action:"read",effect:"allow"}]
);
