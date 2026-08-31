-- ============================================================================
-- TESTS — fn::sanitize_email
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_email(" User@Example.COM ","EMAIL");
