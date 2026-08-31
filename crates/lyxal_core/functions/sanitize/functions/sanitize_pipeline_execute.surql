-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_pipeline_execute
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_pipeline_execute(
    $value: option<any>,
    $field: string,
    $pipeline: array<object>,
    $max_steps: int
) -> any {
    LET $steps = fn::sanitize_pipeline($pipeline,$field,$max_steps);
    RETURN array::fold(
        $steps,
        $value,
        |$current,$step| {
            IF $step.rule = "trim" {
                fn::sanitize_trim($current,$field)
            } ELSE IF $step.rule = "lowercase" {
                fn::sanitize_lowercase($current,$field)
            } ELSE IF $step.rule = "uppercase" {
                fn::sanitize_uppercase($current,$field)
            } ELSE IF $step.rule = "capitalize" {
                fn::sanitize_capitalize($current,$field)
            } ELSE IF $step.rule = "title_case" {
                fn::sanitize_title_case($current,$field)
            } ELSE IF $step.rule = "collapse_whitespace" {
                fn::sanitize_collapse_whitespace($current,$field)
            } ELSE IF $step.rule = "remove_control_chars" {
                fn::sanitize_remove_control_chars(
                    $current,
                    $field,
                    IF $step.options.preserve_layout IS NONE { false } ELSE { $step.options.preserve_layout }
                )
            } ELSE IF $step.rule = "normalize_unicode" {
                fn::sanitize_normalize_unicode(
                    $current,
                    $field,
                    IF $step.options.collapse_whitespace IS NONE { false } ELSE { $step.options.collapse_whitespace }
                )
            } ELSE IF $step.rule = "slug" {
                fn::sanitize_slug(
                    $current,
                    $field,
                    IF $step.value IS NONE { "-" } ELSE { $step.value }
                )
            } ELSE IF $step.rule = "safe_identifier" {
                fn::sanitize_safe_identifier($current,$field)
            } ELSE IF $step.rule = "default" {
                IF $current IS NONE { $step.value } ELSE { $current }
            } ELSE {
                $current
            }
        }
    );
}
COMMENT "Exécute séquentiellement un pipeline fermé de sanitation."
PERMISSIONS FULL;
