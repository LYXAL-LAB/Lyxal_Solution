-- ============================================================================
-- TESTS — fn::sanitize_markdown_tables
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_tables("| A | B |\n|---|---|\n| 1 | 2 |","MD");
