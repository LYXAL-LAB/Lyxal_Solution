-- ============================================================================
-- TESTS — fn::sanitize_markdown
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_markdown("# [Lyxal](https://example.com)\n- **OS**","MD");
