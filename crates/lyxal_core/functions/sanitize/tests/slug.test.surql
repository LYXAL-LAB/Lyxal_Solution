-- ============================================================================
-- TESTS — fn::sanitize_slug
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_slug("  Lyxal OS Core  ","VALUE","-");
