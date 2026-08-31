--
-- GET & POST /v1/booking/event-types
DEFINE API IF NOT EXISTS "/v1/booking/event-types"
    FOR get THEN {
        LET $types = SELECT * FROM booking_event_type WHERE enabled = true ORDER BY created_at DESC;
        RETURN {
            status: 200,
            body: encoding::json::encode($types)
        };
    }
    FOR post THEN {
        LET $body = $request.body;
        LET $created = CREATE booking_event_type CONTENT {
            account: type::record('booking_account', $body.account_id),
            slug: $body.slug,
            title: $body.title,
            description: $body.description,
            duration_min: $body.duration_min,
            location_type: IF $body.location_type != NONE { $body.location_type } ELSE { 'link' },
            location_value: $body.location_value,
            buffer_before: IF $body.buffer_before != NONE { $body.buffer_before } ELSE { 0 },
            buffer_after: IF $body.buffer_after != NONE { $body.buffer_after } ELSE { 0 },
            min_notice_min: IF $body.min_notice_min != NONE { $body.min_notice_min } ELSE { 60 },
            requires_confirmation: IF $body.requires_confirmation != NONE { $body.requires_confirmation } ELSE { false }
        };
        RETURN {
            status: 201,
            body: encoding::json::encode($created[0])
        };
    };