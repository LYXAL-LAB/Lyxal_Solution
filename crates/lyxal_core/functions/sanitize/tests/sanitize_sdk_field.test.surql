-- ============================================================================
-- TESTS — fn::sanitize_sdk_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_sdk_field([{rule:"trim"},{rule:"lowercase"}],"NAME"," A ",NONE);
