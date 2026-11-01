-- ============================================================================
-- TESTS — fn::validation_schema_cache_replace
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_schema_cache_replace(
    [{cache_key:"a",value:1}],
    {cache_key:"a",value:2}
);
