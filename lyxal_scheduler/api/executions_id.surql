-- API pour gérer les exécutions

-- GET /v1/executions/:id
DEFINE API IF NOT EXISTS "/v1/executions/:id"
    FOR get THEN {
        LET $res = SELECT * FROM scheduler_execution WHERE id = type::record('scheduler_execution', $request.path.id);
        IF array::len($res) == 0 {
            RETURN {
                status: 404,
                body: encoding::json::encode({ "error": "Exécution non trouvée" })
            };
        } ELSE {
            RETURN {
                status: 200,
                body: encoding::json::encode($res[0])
            };
        };
    };
