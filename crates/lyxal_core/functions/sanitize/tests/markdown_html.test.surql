-- ============================================================================
-- TESTS — fn::sanitize_markdown_html
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_html("Hello <b>world</b>","MD");
