-- ============================================================================
-- TESTS — fn::sanitize_email_domain
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_email_domain("User@Example.COM","EMAIL");
