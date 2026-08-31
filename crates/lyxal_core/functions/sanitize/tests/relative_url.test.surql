-- ============================================================================
-- TESTS — fn::sanitize_relative_url
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_relative_url("https://example.com/path?a=1","URL");
