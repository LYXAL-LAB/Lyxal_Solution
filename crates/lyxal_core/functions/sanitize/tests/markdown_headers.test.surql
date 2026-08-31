-- ============================================================================
-- TESTS — fn::sanitize_markdown_headers
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_headers("# Titre\n## Sous-titre","MD");
