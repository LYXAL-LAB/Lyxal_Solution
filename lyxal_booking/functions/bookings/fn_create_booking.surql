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
    LET $user_id = $params.user_id;

    IF $event_type_slug IS NONE OR string::len(string::trim($event_type_slug)) = 0 {
        THROW "BOOKING_INVALID_PARAMS: event_type_slug est obligatoire";
    };
    IF $guest_name IS NONE OR string::len(string::trim($guest_name)) = 0 {
        THROW "BOOKING_INVALID_PARAMS: guest_name est obligatoire";
    };
    IF $guest_email IS NONE OR string::len(string::trim($guest_email)) = 0 {
        THROW "BOOKING_INVALID_PARAMS: guest_email est obligatoire";
    };

    -- 1. Chargement du type d'événement
    LET $et_list = SELECT * FROM booking_event_type WHERE slug = $event_type_slug LIMIT 1;
    IF array::len($et_list) = 0 {
        THROW "BOOKING_EVENT_TYPE_NOT_FOUND: Type d'événement introuvable pour ce slug";
    };
    LET $et = $et_list[0];

    -- 2. Traitement des événements d'équipe (Round-Robin ou Disponibilité Collective)
    LET $assigned_host = IF $et.team_id IS NOT NONE AND $et.assignment_mode = "round_robin" {
        -- Appel atomique au Round-Robin avant la création
        fn::booking_round_robin_assign({
            team_id: $et.team_id,
            event_type_id: $et.id,
            start_at: $start_time
        })
    } ELSE {
        $et.owner_user_id
    };

    LET $start_at = type::datetime($start_time);
    LET $duration_min = IF $et.duration_minutes != NONE { type::int($et.duration_minutes) } ELSE { 30 };
    LET $end_at = $start_at + type::duration(string::concat(type::string($duration_min), "m"));

    LET $reschedule_token = rand::uuid::v4();
    LET $cancel_token = rand::uuid::v4();

    -- 3. Création atomique de la réservation
    LET $created = CREATE ONLY booking CONTENT {
        event_type: $et.id,
        owner_user_id: $assigned_host,
        guest_name: string::trim($guest_name),
        guest_email: string::lowercase(string::trim($guest_email)),
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

    RETURN {
        id: string::concat("", $created.id),
        event_type_id: string::concat("", $et.id),
        start_at: type::string($created.start_at),
        end_at: type::string($created.end_at),
        status: $created.status,
        assigned_resource_id: NONE,
        meeting_url: NONE,
        notification_status: "queued",
        calendar_sync_status: "pending",
        guest_name: $created.guest_name,
        guest_email: $created.guest_email
    };
};
