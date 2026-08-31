-- ============================================================================
-- TESTS — fn::sanitize_email_local
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_email_local("mailto:User@example.com","EMAIL");
