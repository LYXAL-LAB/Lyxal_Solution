-- ============================================================================
-- TESTS — fn::security_policy
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_policy(
    "scheduler_policy",
    "v1",
    [{resource:"scheduler::job",action:"read",effect:"allow"}],
    "deny"
);
