-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_object_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_object_pipeline(
    $value: object,
    $steps: array<object>
) -> object {
    RETURN array::reduce(
        $steps,
        |$current,$step| {
            IF $step.rule = "keep_keys" {
                fn::sanitize_keep_keys($current,$step.value)
            } ELSE IF $step.rule = "remove_empty" {
                fn::sanitize_remove_empty($current,true,true,true,true)
            } ELSE IF $step.rule = "defaults" {
                fn::sanitize_default_values($current,$step.value)
            } ELSE {
                $current
            }
        },
        $value
    );
}
COMMENT "Exécute un pipeline fermé de sanitation d'objet."
PERMISSIONS FULL;
