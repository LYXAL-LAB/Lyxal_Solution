-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_pipeline
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_pipeline(
    $value: any,
    $steps: array<object>
) -> any {
    RETURN array::fold(
        $steps,
        $value,
        |$current,$step| {
            IF $step.rule = "email" {
                fn::security_redact_email(<string>$current)
            } ELSE IF $step.rule = "phone" {
                fn::security_redact_phone(
                    <string>$current,
                    IF $step.visible_end IS NONE { 4 } ELSE { $step.visible_end }
                )
            } ELSE IF $step.rule = "card" {
                fn::security_redact_card(<string>$current)
            } ELSE IF $step.rule = "secret" {
                fn::security_redact_secret(
                    <string>$current,
                    IF $step.visible_start IS NONE { 0 } ELSE { $step.visible_start },
                    IF $step.visible_end IS NONE { 4 } ELSE { $step.visible_end }
                )
            } ELSE IF $step.rule = "log" {
                fn::security_redact_log(<string>$current)
            } ELSE IF $step.rule = "object" {
                fn::security_redact_object($current,$step.sensitive_keys)
            } ELSE {
                $current
            }
        }
    );
}
COMMENT "Exécute un pipeline fermé de redaction."
PERMISSIONS FULL;
