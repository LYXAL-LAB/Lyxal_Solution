-- ============================================================================
-- TESTS — fn::sanitize_markdown_images
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_images("![Logo](logo.png)","MD");
