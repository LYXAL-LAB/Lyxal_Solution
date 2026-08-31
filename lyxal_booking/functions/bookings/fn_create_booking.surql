-- ============================================================================
-- LYXAL OS — BOOKING ENGINE
-- ============================================================================
-- Fichier  : functions/bookings/fn_create_booking.surql
-- Fonction : fn::booking_create_booking
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_create_booking($params: object) {
    LET $event_type_slug = $params.event_type_slug;
    LET $start_time = $params.start_time;
    LET $guest_name = $params.guest_name;
    LET $guest_email = $params.guest_email;
    LET $notes = $params.notes;
    LET $user_id = IF $params.user_id != NONE { type::record(type::string($params.user_id)) } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $event_type_slug IS NONE OR string::len(string::trim($event_type_slug)) = 0 {
        RETURN fn::result_error("BOOKING_SLUG_REQUIRED", $language, { field: "event_type_slug" });
    };
    IF $guest_name IS NONE OR string::len(string::trim($guest_name)) = 0 {
        RETURN fn::result_error("BOOKING_GUEST_NAME_REQUIRED", $language, { field: "guest_name" });
    };
    IF $guest_email IS NONE OR string::len(string::trim($guest_email)) = 0 {
        RETURN fn::result_error("BOOKING_GUEST_EMAIL_REQUIRED", $language, { field: "guest_email" });
    };

    -- 1. Chargement du type d'événement
    LET $clean_slug = string::lowercase(string::trim($event_type_slug));
    LET $et_list = SELECT * FROM booking_event_type WHERE slug = $clean_slug LIMIT 1;
    IF array::len($et_list) = 0 {
        RETURN fn::result_error("BOOKING_EVENT_TYPE_NOT_FOUND", $language, { slug: $clean_slug });
    };
    LET $et = $et_list[0];

    -- 2. Hôte affecté
    LET $assigned_host = IF $user_id != NONE {
        $user_id
    } ELSE IF $et.account != NONE {
        $et.account
    } ELSE {
        NONE
    };

    LET $start_at = type::datetime($start_time);
    LET $duration_min = IF $et.duration_min != NONE { type::int($et.duration_min) } ELSE { 30 };
    LET $end_at = $start_at + type::duration(string::concat(type::string($duration_min), "m"));

    LET $reschedule_token = rand::uuid::v4();
    LET $cancel_token = rand::uuid::v4();
    LET $uid = rand::uuid::v4();

    -- 3. Création atomique de la réservation
    LET $created = CREATE ONLY booking CONTENT {
        event_type: $et.id,
        host: $assigned_host,
        guest_name: string::trim($guest_name),
        guest_email: string::lowercase(string::trim($guest_email)),
        uid: $uid,
        start_at: $start_at,
        end_at: $end_at,
        status: IF $et.requires_confirmation == true { 'pending' } ELSE { 'confirmed' },
        notes: IF $notes IS NOT NONE { string::trim($notes) } ELSE { NONE },
        reschedule_token: $reschedule_token,
        cancel_token: $cancel_token,
        created_at: time::now()
    };

    -- 4. Émission de l'événement outbox pour notifications / sync externe
    CREATE ONLY event_outbox CONTENT {
        event_type: "booking.created",
        payload: {
            booking_id: $created.id,
            guest_email: $created.guest_email,
            host_user_id: $assigned_host,
            start_at: $created.start_at,
            end_at: $created.end_at
        },
        created_at: time::now()
    };

    RETURN fn::result_ok({
        id: $created.id,
        event_type: $et.id,
        guest_name: $created.guest_name,
        guest_email: $created.guest_email,
        status: $created.status,
        cancel_token: $created.cancel_token,
        reschedule_token: $created.reschedule_token,
        start_at: $created.start_at,
        end_at: $created.end_at
    });
};
