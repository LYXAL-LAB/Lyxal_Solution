-- ============================================================================
-- TESTS — fn::sanitize_strip_iframes
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_iframes("<iframe src='x'></iframe><p>ok</p>","HTML");
