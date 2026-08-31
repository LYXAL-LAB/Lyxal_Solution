-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_sdk_execute
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_sdk_execute(
    $schema: object,
    $payload: object,
    $options: option<object>
) -> object {
    LET $request = fn::security_sdk_request(
        $schema,
        $payload,
        $options
    );

    RETURN fn::security_runtime_validate(
        $schema,
        $payload,
        $request.options.mode,
        $request.options.max_steps,
        NONE
    );
}
COMMENT "Compile puis exécute un schéma via le Security SDK."
PERMISSIONS FULL;
