-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_compile
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_compile(
    $pipeline: array<object>,
    $name: string,
    $version: string,
    $max_steps: int
) -> object {
    LET $steps = fn::security_pipeline($pipeline,$name,$max_steps);
    RETURN {
        name:string::lowercase(string::trim($name)),
        version:string::lowercase(string::trim($version)),
        steps:$steps,
        step_count:array::len($steps),
        compiled_at:time::now()
    };
}
COMMENT "Compile un pipeline Security."
PERMISSIONS FULL;
