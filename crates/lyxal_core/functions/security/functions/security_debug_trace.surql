-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_trace
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_trace(
    $field: string,
    $rule: string,
    $input: option<any>,
    $output: option<any>,
    $finding: option<object>,
    $decision: option<object>,
    $started_at: datetime,
    $completed_at: datetime
) -> object {
    RETURN {
        field:string::trim($field),
        rule:string::lowercase(string::trim($rule)),
        input:$input,
        output:$output,
        changed:$input != $output,
        finding:$finding,
        decision:$decision,
        started_at:$started_at,
        completed_at:$completed_at,
        duration:$completed_at-$started_at
    };
}
COMMENT "Construit une trace d'exécution Security."
PERMISSIONS FULL;
