-- API pour gérer les dead-letters

-- DELETE /v1/dead-letters/:id
DEFINE API IF NOT EXISTS "/v1/dead-letters/:id"
    FOR delete THEN {
        DELETE type::record('scheduler_dead_letter', $request.path.id);
        RETURN {
            status: 200,
            body: encoding::json::encode({ "success": true, "deleted_id": $request.path.id })
        };
    };
