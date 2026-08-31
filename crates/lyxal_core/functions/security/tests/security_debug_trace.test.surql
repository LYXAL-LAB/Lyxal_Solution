-- ============================================================================
-- TESTS — fn::security_debug_trace
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_debug_trace(
    "payload",
    "detect_payload",
    "<script>x</script>",
    "<script>x</script>",
    {detected:true,score:60},
    NONE,
    d"2026-08-03T12:00:00Z",
    d"2026-08-03T12:00:01Z"
);
