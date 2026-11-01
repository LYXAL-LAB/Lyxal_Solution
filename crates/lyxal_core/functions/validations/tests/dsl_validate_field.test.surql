-- ============================================================================
-- TESTS — fn::validation_dsl_validate_field
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_dsl_validate_field(
    "slug",
    {
        type:"string",
        trim:true,
        lowercase:true,
        min_length:3
    }
);
