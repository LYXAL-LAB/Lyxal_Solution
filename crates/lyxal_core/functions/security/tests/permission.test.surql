-- ============================================================================
-- TESTS — fn::security_permission
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_permission(
    "scheduler::job",
    "read",
    "allow",
    {tenant:"acme"}
);
