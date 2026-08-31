-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_failed
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_failed(
    $session: object
) -> array<object> {
    RETURN array::filter(
        $session.traces,
        |$trace|
            ($trace.finding IS NOT NONE AND $trace.finding.detected = true)
            OR ($trace.decision IS NOT NONE AND $trace.decision.allowed = false)
    );
}
COMMENT "Retourne les traces Security ayant produit une alerte ou un refus."
PERMISSIONS FULL;
