-- ============================================================================
-- TESTS — fn::security_role
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_role(
    "scheduler::operator",
    [{resource:"scheduler::job",action:"read",effect:"allow"}],
    ["base::user"],
    true
);
