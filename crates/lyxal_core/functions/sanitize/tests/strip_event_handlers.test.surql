-- ============================================================================
-- TESTS — fn::sanitize_strip_event_handlers
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::sanitize_strip_event_handlers("<button onclick=\"x()\">ok</button>","HTML");
