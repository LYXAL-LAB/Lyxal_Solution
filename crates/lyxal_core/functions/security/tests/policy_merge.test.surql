-- ============================================================================
-- TESTS — fn::security_policy_merge
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_policy_merge(
    {
        permissions:[{resource:"a",action:"read",effect:"allow"}],
        default_effect:"deny"
    },
    {
        permissions:[{resource:"a",action:"write",effect:"allow"}],
        default_effect:"deny"
    },
    "merged",
    "v1"
);
