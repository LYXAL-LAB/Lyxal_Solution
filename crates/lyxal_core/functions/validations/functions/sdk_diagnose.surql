-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_diagnose
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_diagnose(
    $schema: object,
    $cache_entries: array<object>,
    $registry_entries: array<object>,
    $now: datetime
) -> object {
    LET $compiled = fn::validation_sdk_compile(
        $schema,
        true
    );

    RETURN {
        sdk: fn::validation_sdk_version(),
        capabilities: fn::validation_sdk_capabilities(),
        compiled_schema:
            fn::validation_compiled_schema_info($compiled),
        optimizer: fn::validation_optimizer_report(
            fn::validation_schema_compile(
                $schema.name,
                $schema.version,
                $schema.schema
            ),
            $compiled
        ),
        runtime: fn::validation_runtime_health(
            $registry_entries,
            $cache_entries,
            $now
        )
    };
}
COMMENT "
Produit un diagnostic global du moteur pour un schéma.
"
PERMISSIONS FULL;
