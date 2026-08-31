-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_request
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_request(
    $schema: object,
    $payload: any,
    $options: option<object>
) -> object {
    IF $schema.name IS NONE
        OR $schema.version IS NONE
        OR $schema.fields IS NONE
    {
        THROW "SECURITY_SDK_INVALID_SCHEMA";
    };

    RETURN {
        schema:$schema,
        payload:$payload,
        options:IF $options IS NONE {
            {
                mode:"enforce",
                optimize:true,
                max_steps:50,
                debug:false
            }
        } ELSE {
            object::extend(
                {
                    mode:"enforce",
                    optimize:true,
                    max_steps:50,
                    debug:false
                },
                $options
            )
        }
    };
}
COMMENT "Construit une requête publique du Security SDK."
PERMISSIONS FULL;
