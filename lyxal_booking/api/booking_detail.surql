-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  API de détails et d'annulation d'une réservation                        │
-- └──────────────────────────────────────────────────────────────────────────┘

-- GET & DELETE /v1/booking/bookings/:id
DEFINE API IF NOT EXISTS "/v1/booking/bookings/:id"
    FOR get THEN {
        LET $res = SELECT * FROM booking WHERE id = type::record('booking', $request.path.id);
        IF array::len($res) == 0 {
            RETURN {
                status: 404,
                body: encoding::json::encode({ "error": "Réservation non trouvée" })
            };
        } ELSE {
            RETURN {
                status: 200,
                body: encoding::json::encode($res[0])
            };
        };
    }
    FOR delete THEN {
        LET $target = type::record('booking', $request.path.id);
        UPDATE $target SET status = 'cancelled';
        RETURN {
            status: 200,
            body: encoding::json::encode({ "success": true, "cancelled_id": $request.path.id })
        };
    };