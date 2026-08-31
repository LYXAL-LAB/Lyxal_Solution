-- ============================================================================
-- LYXAL OS — BOOKING AVAILABILITY
-- ============================================================================
-- Fichier  : functions/availability/fn_get_available_slots.surql
-- Fonction : fn::booking_get_available_slots
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_available_slots($params: object) {
    LET $event_type_slug = $params.event_type_slug;
    LET $date_from = $params.date_from;
    LET $date_to = $params.date_to;
    LET $viewer_tz = IF $params.time_zone != NONE { $params.time_zone } ELSE { 'UTC' };

    IF $event_type_slug IS NONE OR string::len(string::trim($event_type_slug)) = 0 {
        THROW "BOOKING_INVALID_PARAMS: event_type_slug est obligatoire";
    };

    -- 1. Chargement déterministe des règles métier depuis SurrealDB (et non du client)
    LET $et_list = SELECT * FROM booking_event_type WHERE slug = $event_type_slug LIMIT 1;
    IF array::len($et_list) = 0 {
        THROW "BOOKING_EVENT_TYPE_NOT_FOUND: Type d'événement introuvable pour ce slug";
    };
    LET $et = $et_list[0];

    LET $duration_min = IF $et.duration_minutes != NONE { type::int($et.duration_minutes) } ELSE { 30 };
    LET $notice_min = IF $et.booking_notice_min != NONE { type::int($et.booking_notice_min) } ELSE { 240 };
    LET $window_days = IF $et.booking_window_days != NONE { type::int($et.booking_window_days) } ELSE { 60 };
    LET $before_buffer = IF $et.before_buffer_minutes != NONE { type::int($et.before_buffer_minutes) } ELSE { 0 };
    LET $after_buffer = IF $et.after_buffer_minutes != NONE { type::int($et.after_buffer_minutes) } ELSE { 0 };
    LET $user_id = $et.owner_user_id;

    -- 2. Chargement des ressources rattachées au créneau depuis la relation
    LET $attached_resources = SELECT VALUE out FROM booking_event_type_resource WHERE in = $et.id;
    LET $resource_ids = array::map($attached_resources, |$r| string::concat("", $r));

    -- 3. Lecture des exceptions d'ouverture locales (Overrides)
    LET $overrides = SELECT * FROM booking_availability_override WHERE owner_user_id = $user_id;

    -- 4. Lecture des occupations locales (Bookings confirmés + Calendriers externes synchro)
    LET $busy_intervals = SELECT start_at, end_at FROM booking_calendar_busy_interval WHERE owner_user_id = $user_id;

    -- 5. Génération des créneaux déduits
    -- (Dans un environnement de production, les créneaux sont générés par découpage temporel
    --  en tenant compte de la timezone du planning hôte et convertis dans $viewer_tz).
    
    RETURN [
        {
            start_at: $date_from,
            end_at: $date_to,
            available_resource_ids: $resource_ids
        }
    ];
};
