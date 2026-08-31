-- API pour supprimer un déclencheur

-- DELETE /v1/schedules/:id
DEFINE API IF NOT EXISTS "/v1/schedules/:id"
    FOR delete THEN {
        DELETE type::record('scheduler_trigger', $request.path.id);
        RETURN {
            status: 200,
            body: encoding::json::encode({ "success": true, "deleted_id": $request.path.id })
        };
    };
