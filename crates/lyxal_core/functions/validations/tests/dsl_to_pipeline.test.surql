-- ============================================================================
-- TESTS — fn::validation_dsl_to_pipeline
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_to_pipeline(
    {
        required:true,
        trim:true,
        lowercase:true,
        min_length:3
    }
);
