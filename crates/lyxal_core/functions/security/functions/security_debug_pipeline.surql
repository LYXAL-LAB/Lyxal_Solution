-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_pipeline(
    $name: string,
    $pipeline: array<object>,
    $execution: object
) -> object {
    RETURN {
        name:string::trim($name),
        pipeline:$pipeline,
        stats:fn::security_pipeline_stats($pipeline),
        findings:$execution.findings,
        decisions:$execution.decisions,
        output:$execution.value
    };
}
COMMENT "Construit une vue debug d'un pipeline Security."
PERMISSIONS FULL;
