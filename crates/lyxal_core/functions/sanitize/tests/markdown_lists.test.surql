-- ============================================================================
-- TESTS — fn::sanitize_markdown_lists
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_lists("- A\n1. B","MD");
