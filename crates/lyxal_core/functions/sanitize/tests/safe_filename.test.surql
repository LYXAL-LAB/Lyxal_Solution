-- ============================================================================
-- TESTS — fn::sanitize_safe_filename
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_safe_filename("rapport:final?.pdf","VALUE","_");
