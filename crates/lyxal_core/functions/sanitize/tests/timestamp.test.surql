-- ============================================================================
-- TESTS — fn::sanitize_timestamp
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_timestamp(
    d"2026-08-03T15:42:10Z",
    "seconds"
);
