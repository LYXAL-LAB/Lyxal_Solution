-- ============================================================================
-- TESTS — fn::security_schema_cache
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_schema_cache({name:"req",version:"v1"},1h,d"2026-08-03T12:00:00Z");
