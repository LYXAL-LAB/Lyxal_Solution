
-- Log événement d'exécution

DEFINE FUNCTION IF NOT EXISTS fn::logic_event_log(
    $tenant: string, $level: string, $message: string, $data: object, 
    $workflow: option<string>, $version: option<string>, $step: option<string>, 
    $trace_id: string, $span_id: string) {

    CREATE logic_event SET

        tenant = type::record('tenant', $tenant),
        level = $level,
        message = $message,
        data = $data,
        workflow = type::record('logic_workflow', $workflow),
        version = type::record('logic_version', $version),
        step = type::record('logic_step', $step),
        trace_id = $trace_id,
        span_id = $span_id;
}
COMMENT "Log événement d'exécution"
PERMISSIONS FULL;