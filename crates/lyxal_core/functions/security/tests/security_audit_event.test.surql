-- ============================================================================
-- TESTS — fn::security_audit_event
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_audit_event(
    "permission_check",
    "user:123",
    "scheduler::job",
    "delete",
    "denied",
    {reason:"policy"},
    d"2026-08-03T12:00:00Z"
);
