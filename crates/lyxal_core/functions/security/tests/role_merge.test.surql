-- ============================================================================
-- TESTS — fn::security_role_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_role_merge(
    {
        name:"base",
        permissions:[{resource:"a",action:"read",effect:"allow"}],
        inherits:[],
        enabled:true
    },
    {
        permissions:[{resource:"a",action:"write",effect:"allow"}]
    }
);
