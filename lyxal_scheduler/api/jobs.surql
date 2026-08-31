-- API de gestion des jobs planifiés

-- GET & POST /v1/jobs
DEFINE API IF NOT EXISTS "/v1/jobs"
    FOR get THEN {
        LET $jobs = SELECT 
            id,
            definition,
            next_fire_at,
            last_fired_at,
            fire_count,
            status,
            created_at,
            updated_at
        FROM scheduler_job ORDER BY created_at DESC;
        RETURN {
            status: 200,
            body: encoding::json::encode($jobs)
        };
    }
    FOR post THEN {
        LET $body = $request.body;
        LET $active = IF $body.is_active != NONE { $body.is_active } ELSE { true };
        LET $timeout = IF $body.timeout != NONE { $body.timeout } ELSE { '5m' };
        LET $retries = IF $body.max_retries != NONE { $body.max_retries } ELSE { 3 };
        LET $dl_enabled = IF $body.dead_letter_enabled != NONE { $body.dead_letter_enabled } ELSE { true };
        LET $metadata = IF $body.metadata != NONE { $body.metadata } ELSE { {} };
        LET $tags = IF $body.tags != NONE { $body.tags } ELSE { [] };
        
        LET $created_def = CREATE scheduler_job_definition CONTENT {
            description: $body.description,
            assigned_runner_id: $body.assigned_runner_id,
            is_active: $active,
            metadata: $metadata,
            tags: $tags,
            timeout: $timeout,
            max_retries: $retries,
            dead_letter_enabled: $dl_enabled
        };
        
        LET $next_fire = IF $body.next_fire_at != NONE { $body.next_fire_at } ELSE { time::now() };
        LET $job_status = IF $active == false { 'paused' } ELSE { 'active' };
        
        LET $created_job = CREATE scheduler_job CONTENT {
            definition: $created_def[0].id,
            status: $job_status,
            next_fire_at: $next_fire
        };
        RETURN {
            status: 201,
            body: encoding::json::encode($created_job[0])
        };
    };
