-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_summary
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_summary(
    $session: object
) -> object {
    LET $findings = array::filter(
        $session.traces,
        |$trace| $trace.finding IS NOT NONE
    );

    LET $decisions = array::filter(
        $session.traces,
        |$trace| $trace.decision IS NOT NONE
    );

    RETURN {
        request_id:$session.request_id,
        schema_name:$session.schema_name,
        trace_count:array::len($session.traces),
        finding_count:array::len($findings),
        decision_count:array::len($decisions),
        started_at:$session.started_at
    };
}
COMMENT "Produit le résumé d'une session Security."
PERMISSIONS FULL;
