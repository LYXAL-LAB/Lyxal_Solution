-- ============================================================================
-- TESTS — fn::sanitize_url
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_url(" https://example.com/a b ","URL");
