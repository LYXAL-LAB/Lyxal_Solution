-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fonction : fn::validation_sdk_version
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_sdk_version() -> object {
    RETURN {
        name: "lyxal_validation_sdk",
        version: "1.0.0",
        contract_version: "v1",
        engine_lots: {
            primitives: "1-17",
            engine: 18,
            pipeline: 19,
            reports: 20,
            nested_schema: 21,
            compiler: 22,
            cache: 23,
            registry: 24,
            dsl: 25,
            runtime: 26,
            optimizer: 27,
            debug: 28,
            benchmark: 29,
            sdk: 30
        }
    };
}
COMMENT "
Retourne la version publique du Validation SDK Lyxal.
"
PERMISSIONS FULL;
