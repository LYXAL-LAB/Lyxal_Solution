-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_report(
    $session: object
) -> object {
    LET $count = array::len($session.traces);

    RETURN {
        summary:fn::security_debug_summary($session),
        alerts:fn::security_debug_failed($session),
        slowest:IF $count = 0 {
            []
        } ELSE {
            fn::security_debug_slowest(
                $session,
                IF $count < 5 { $count } ELSE { 5 }
            )
        },
        traces:$session.traces,
        generated_at:time::now()
    };
}
COMMENT "Produit le rapport complet d'une session Security."
PERMISSIONS FULL;
