-- ============================================================================
-- TESTS — fn::validation_dsl_normalize_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_normalize_field(
    {type:"string",trim:true}
);
