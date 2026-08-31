-- ============================================================================
-- TESTS — fn::security_audit_verify
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

LET $chain = fn::security_audit_chain([
    {event_id:rand::uuid::v7(),action:"read"}
]);
RETURN fn::security_audit_verify($chain);
