-- ============================================================================
-- TESTS — fn::security_audit_chain
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_audit_chain([
    {event_id:rand::uuid::v7(),action:"read"},
    {event_id:rand::uuid::v7(),action:"write"}
]);
