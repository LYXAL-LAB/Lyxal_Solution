-- ============================================================================
-- TESTS — fn::sanitize_query
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_query("?a=1&b=2#frag","QUERY");
