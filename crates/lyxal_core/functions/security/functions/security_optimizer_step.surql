-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_step
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_step(
    $step: object
) -> object {
    LET $cost = IF string::starts_with($step.rule,"detect_") {
        3
    } ELSE IF string::starts_with($step.rule,"redact_") {
        2
    } ELSE IF $step.rule = "permission_check" {
        4
    } ELSE {
        6
    };

    RETURN object::extend($step,{_cost:$cost});
}
COMMENT "Ajoute un coût relatif à une étape Security."
PERMISSIONS FULL;
