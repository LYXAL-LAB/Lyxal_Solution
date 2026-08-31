-- API de gestion des déclencheurs/schedules

-- GET & POST /v1/schedules
DEFINE API IF NOT EXISTS "/v1/schedules"
    FOR get THEN {
        LET $schedules = SELECT * FROM scheduler_trigger ORDER BY created_at DESC;
        RETURN {
            status: 200,
            body: encoding::json::encode($schedules)
        };
    }
    FOR post THEN {
        LET $body = $request.body;
        LET $is_enabled = IF $body.enabled != NONE { $body.enabled } ELSE { true };
        LET $tz = IF $body.timezone != NONE { $body.timezone } ELSE { 'UTC' };
        
        LET $created = CREATE scheduler_trigger CONTENT {
            job_key: type::record('scheduler_job_definition', $body.job_id),
            cron_expression: $body.cron_expression,
            timezone: $tz,
            calendar: $body.calendar,
            window: $body.window,
            not_before: $body.not_before,
            not_after: $body.not_after,
            enabled: $is_enabled
        };
        RETURN {
            status: 201,
            body: encoding::json::encode($created[0])
        };
    };
