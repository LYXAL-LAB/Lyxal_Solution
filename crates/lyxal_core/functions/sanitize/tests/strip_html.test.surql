-- ============================================================================
-- TESTS — fn::sanitize_strip_html
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_html("<p>Lyxal <strong>OS</strong></p>","HTML");
