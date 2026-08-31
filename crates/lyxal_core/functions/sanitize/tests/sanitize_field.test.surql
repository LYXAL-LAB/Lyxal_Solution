-- ============================================================================
-- TESTS — fn::sanitize_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_field(
 "name",
 [{rule:"trim"},{rule:"lowercase"}],
 NONE,
 false
);
