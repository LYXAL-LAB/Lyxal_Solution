-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_report(
    $original: array<object>,
    $optimized: array<object>
) -> object {
    RETURN {
        original_steps:array::len($original),
        optimized_steps:array::len($optimized),
        original_cost:fn::security_optimizer_cost($original),
        optimized_cost:fn::security_optimizer_cost($optimized),
        saved_steps:array::len($original)-array::len($optimized),
        generated_at:time::now()
    };
}
COMMENT "Produit un rapport d'optimisation Security."
PERMISSIONS FULL;
