-- ============================================================================
-- TESTS — fn::sanitize_remove_tracking
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_remove_tracking("https://x.test?a=1&utm_source=mail&fbclid=abc","URL");
