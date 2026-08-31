-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_pipeline_execute
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_pipeline_execute(
    $value: any,
    $pipeline: array<object>,
    $context: option<object>
) -> object {
    LET $ctx = IF $context IS NONE{{}}ELSE{$context};

    RETURN array::fold(
        $pipeline,
        {value:$value,findings:[],decisions:[]},
        |$state,$step| {
            IF $step.rule = "detect_payload" {
                LET $result = fn::security_detect_payload(<string>$state.value);
                object::extend($state,{
                    findings:array::append($state.findings,$result)
                })
            } ELSE IF $step.rule = "detect_file" {
                LET $result = fn::security_detect_file_attack(
                    $step.options.filename,
                    $step.options.mime
                );
                object::extend($state,{
                    findings:array::append($state.findings,$result)
                })
            } ELSE IF $step.rule = "redact_email" {
                object::extend($state,{value:fn::security_redact_email(<string>$state.value)})
            } ELSE IF $step.rule = "redact_phone" {
                object::extend($state,{value:fn::security_redact_phone(<string>$state.value,4)})
            } ELSE IF $step.rule = "redact_card" {
                object::extend($state,{value:fn::security_redact_card(<string>$state.value)})
            } ELSE IF $step.rule = "redact_secret" {
                object::extend($state,{value:fn::security_redact_secret(<string>$state.value,0,4)})
            } ELSE IF $step.rule = "redact_log" {
                object::extend($state,{value:fn::security_redact_log(<string>$state.value)})
            } ELSE IF $step.rule = "redact_object" {
                object::extend($state,{value:fn::security_redact_object($state.value,$step.options.sensitive_keys)})
            } ELSE IF $step.rule = "permission_check" {
                LET $decision = fn::security_permission_check(
                    $step.options.permissions,
                    $step.options.resource,
                    $step.options.action,
                    $ctx
                );
                object::extend($state,{
                    decisions:array::append($state.decisions,$decision)
                })
            } ELSE {
                $state
            }
        }
    );
}
COMMENT "Exécute un pipeline Security fermé."
PERMISSIONS FULL;
