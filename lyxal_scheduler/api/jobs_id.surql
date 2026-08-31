-- API pour gérer les jobs

-- GET & DELETE /v1/jobs/:id
DEFINE API IF NOT EXISTS "/v1/jobs/:id"
    FOR get THEN {
        LET $job = SELECT * FROM scheduler_job WHERE id = type::record('scheduler_job', $request.path.id);
        IF array::len($job) == 0 {
            RETURN {
                status: 404,
                body: encoding::json::encode({ "error": "Job non trouvé" })
            };
        } ELSE {
            RETURN {
                status: 200,
                body: encoding::json::encode($job[0])
            };
        };
    }
    FOR delete THEN {
        LET $target = type::record('scheduler_job', $request.path.id);
        DELETE $target;
        RETURN {
            status: 200,
            body: encoding::json::encode({ "success": true, "deleted_id": $request.path.id })
        };
    };
