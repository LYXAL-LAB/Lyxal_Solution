-- ============================================================================
-- TESTS — fn::sanitize_strip_styles
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_styles("<style>body{{}}</style><p>ok</p>","HTML");
