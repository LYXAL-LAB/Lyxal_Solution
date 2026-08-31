-- API des exécutions de tâches

-- GET /v1/executions
DEFINE API IF NOT EXISTS "/v1/executions"
    FOR get THEN {
        LET $limit = IF $request.query.limit != NONE { type::int($request.query.limit) } ELSE { 50 };
        LET $state = $request.query.state;
        LET $executions = IF $state != NONE {
            SELECT * FROM scheduler_execution WHERE state = $state ORDER BY fire_at DESC LIMIT $limit
        } ELSE {
            SELECT * FROM scheduler_execution ORDER BY fire_at DESC LIMIT $limit
        };
        RETURN {
            status: 200,
            body: encoding::json::encode($executions)
        };
    };
