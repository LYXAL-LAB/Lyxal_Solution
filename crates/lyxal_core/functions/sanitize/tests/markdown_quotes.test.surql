-- ============================================================================
-- TESTS — fn::sanitize_markdown_quotes
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_quotes("> Citation\n> Suite","MD");
