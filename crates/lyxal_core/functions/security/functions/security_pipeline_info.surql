-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_info
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_info(
    $compiled: object
) -> object {
    RETURN {
        name:$compiled.name,
        version:$compiled.version,
        step_count:array::len($compiled.steps),
        rules:array::map($compiled.steps,|$s|$s.rule),
        compiled_at:$compiled.compiled_at
    };
}
COMMENT "Retourne les métadonnées d'un pipeline compilé."
PERMISSIONS FULL;
