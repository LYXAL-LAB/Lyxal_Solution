-- ============================================================================
-- TESTS — fn::sanitize_strip_scripts
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_scripts("<p>ok</p><script>alert(1)</script>","HTML");
