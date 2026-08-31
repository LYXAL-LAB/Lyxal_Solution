--API des dead-letters

-- GET /v1/dead-letters
DEFINE API IF NOT EXISTS "/v1/dead-letters"
    FOR get THEN {
        LET $dl = SELECT * FROM scheduler_dead_letter ORDER BY failed_at DESC;
        RETURN {
            status: 200,
            body: encoding::json::encode($dl)
        };
    };
