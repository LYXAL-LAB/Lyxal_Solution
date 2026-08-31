-- ============================================================================
-- TESTS — fn::sanitize_absolute_url
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_absolute_url("example.com/path","URL","https");
