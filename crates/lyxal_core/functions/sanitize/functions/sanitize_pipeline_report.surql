-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_report(
    $field: string,
    $input: option<any>,
    $output: option<any>,
    $pipeline: array<object>
) -> object {
    RETURN {
        field: string::trim($field),
        changed: $input != $output,
        input: $input,
        output: $output,
        stats: fn::sanitize_pipeline_stats($pipeline),
        generated_at: time::now()
    };
}
COMMENT "Produit un rapport d'exécution de pipeline."
PERMISSIONS FULL;
