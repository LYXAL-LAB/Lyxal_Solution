-- ============================================================================
-- TESTS — fn::sanitize_markdown_safe
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown_safe("[x](javascript:alert(1))<script>x</script>","MD");
