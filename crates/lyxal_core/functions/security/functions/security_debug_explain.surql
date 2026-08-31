-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_explain
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_explain(
    $trace: object
) -> object {
    RETURN {
        field:$trace.field,
        rule:$trace.rule,
        changed:$trace.changed,
        detected:IF $trace.finding IS NONE{false}ELSE{$trace.finding.detected},
        allowed:IF $trace.decision IS NONE{NONE}ELSE{$trace.decision.allowed},
        explanation:string::concat(
            "La règle ",
            $trace.rule,
            " a été exécutée sur le champ ",
            $trace.field,
            "."
        )
    };
}
COMMENT "Explique une trace Security."
PERMISSIONS FULL;
