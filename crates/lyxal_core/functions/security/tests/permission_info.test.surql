-- ============================================================================
-- TESTS — fn::security_permission_info
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_permission_info(
    [
        {resource:"a",action:"read",effect:"allow"},
        {resource:"a",action:"delete",effect:"deny"}
    ]
);
