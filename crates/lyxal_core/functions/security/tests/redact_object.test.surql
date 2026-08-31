-- ============================================================================
-- TESTS — fn::security_redact_object
-- Les tests provoquant un THROW doivent être exécutés individuellement.
-- ============================================================================

RETURN fn::security_redact_object(
    {
        username:"yaniss",
        password:"secret",
        api_key:"abc"
    },
    ["password","api_key"]
);
