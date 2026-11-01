-- ============================================================================
-- TESTS — fn::validation_sdk_request
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::validation_sdk_request(
    {
        name:"user",
        version:"v1",
        schema:{name:{required:true}}
    },
    {name:"Lyxal"},
    NONE
);
