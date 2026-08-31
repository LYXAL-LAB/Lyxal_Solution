-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_validate_dsl
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_validate_dsl(
    $dsl: object,
    $payload: object,
    $options: option<object>
) -> object {
    LET $validated_dsl =
        fn::validation_dsl_validate_object($dsl);

    LET $schema = {
        name: $validated_dsl.name,
        version: $validated_dsl.version,
        schema: $validated_dsl.fields
    };

    RETURN fn::validation_sdk_validate_object(
        $schema,
        $payload,
        $options
    );
}
COMMENT "
Valide un objet directement depuis le DSL public.
"
PERMISSIONS FULL;
