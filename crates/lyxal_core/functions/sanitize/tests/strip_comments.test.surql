-- ============================================================================
-- TESTS — fn::sanitize_strip_comments
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_comments("a<!-- secret -->b","HTML");
