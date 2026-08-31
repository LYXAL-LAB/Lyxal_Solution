-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_report(
    $name: string,
    $execution: object,
    $pipeline: array<object>
) -> object {
    RETURN {
        name:string::trim($name),
        blocked:array::any($execution.decisions,|$d|$d.allowed=false),
        finding_count:array::len($execution.findings),
        decision_count:array::len($execution.decisions),
        stats:fn::security_pipeline_stats($pipeline),
        generated_at:time::now()
    };
}
COMMENT "Produit un rapport d'exécution de pipeline Security."
PERMISSIONS FULL;
