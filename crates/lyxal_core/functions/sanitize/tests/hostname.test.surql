-- ============================================================================
-- TESTS — fn::sanitize_hostname
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_hostname(" My_Host.Example.COM ","HOST");
