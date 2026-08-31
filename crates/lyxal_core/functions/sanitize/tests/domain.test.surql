-- ============================================================================
-- TESTS — fn::sanitize_domain
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_domain("HTTPS://WWW.Example.COM/path","DOMAIN");
