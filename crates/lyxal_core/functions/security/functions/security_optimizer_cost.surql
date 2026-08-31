-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_cost
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_cost(
    $pipeline: array<object>
) -> int {
    RETURN array::fold(
        $pipeline,
        0,
        |$total,$step| $total + fn::security_optimizer_step($step)._cost
    );
}
COMMENT "Calcule le coût relatif d'un pipeline Security."
PERMISSIONS FULL;
