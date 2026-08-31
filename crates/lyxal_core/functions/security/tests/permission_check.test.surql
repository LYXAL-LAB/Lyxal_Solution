-- ============================================================================
-- TESTS — fn::security_permission_check
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_permission_check(
    [
        {resource:"scheduler::job",action:"read",effect:"allow"},
        {resource:"scheduler::job",action:"delete",effect:"deny"}
    ],
    "scheduler::job",
    "read",
    NONE
);
