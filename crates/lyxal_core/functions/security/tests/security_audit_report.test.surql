-- ============================================================================
-- TESTS — fn::security_audit_report
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

LET $chain = fn::security_audit_chain([
    {
        event_id:rand::uuid::v7(),
        action:"read",
        occurred_at:d"2026-08-03T12:00:00Z"
    }
]);
RETURN fn::security_audit_report($chain);
