-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_request
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_request(
    $schema: object,
    $payload: any,
    $options: option<object>
) -> object {
    IF $schema.name IS NONE
        OR $schema.version IS NONE
        OR $schema.schema IS NONE
    {
        THROW "VALIDATION_SDK_INVALID_SCHEMA";
    };

    RETURN {
        schema: $schema,
        payload: $payload,
        options: IF $options IS NONE {
            {
                mode: "fail_fast",
                optimize: true,
                debug: false,
                benchmark: false,
                max_steps: 50,
                cache_ttl: 1h
            }
        } ELSE {
            object::extend(
                {
                    mode: "fail_fast",
                    optimize: true,
                    debug: false,
                    benchmark: false,
                    max_steps: 50,
                    cache_ttl: 1h
                },
                $options
            )
        }
    };
}
COMMENT "
Construit une requête publique du Validation SDK.
"
PERMISSIONS FULL;
