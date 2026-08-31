-- ============================================================================
-- TESTS — fn::security_redact_ip
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_ip("192.168.1.42");
