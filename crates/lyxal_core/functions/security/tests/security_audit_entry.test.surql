-- ============================================================================
-- TESTS — fn::security_audit_entry
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_audit_entry(
    {event_id:rand::uuid::v7(),action:"read"},
    NONE
);
