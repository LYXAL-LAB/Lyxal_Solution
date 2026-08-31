-- ============================================================================
-- TESTS — fn::security_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_field("email",[{rule:"redact_email"}],true,"pii");
