-- ============================================================================
-- TESTS — fn::sanitize_markdown_code
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_code("Texte `code`\n```js\nx()\n```","MD");
