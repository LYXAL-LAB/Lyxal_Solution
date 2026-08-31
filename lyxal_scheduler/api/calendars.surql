-- API des calendriers d'exceptions

-- GET & POST /v1/calendars
DEFINE API IF NOT EXISTS "/v1/calendars"
    FOR get THEN {
        LET $cals = SELECT * FROM scheduler_calendar ORDER BY name ASC;
        RETURN {
            status: 200,
            body: encoding::json::encode($cals)
        };
    }
    FOR post THEN {
        LET $body = $request.body;
        LET $tz = IF $body.timezone != NONE { $body.timezone } ELSE { 'UTC' };
        
        LET $created = CREATE scheduler_calendar CONTENT {
            name: $body.name,
            description: $body.description,
            dates: $body.dates,
            timezone: $tz
        };
        RETURN {
            status: 201,
            body: encoding::json::encode($created[0])
        };
    };