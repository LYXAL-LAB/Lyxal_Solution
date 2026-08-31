-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_event_type                                          â”‚
-- â”‚  Mise Ã  jour complÃ¨te des paramÃ¨tres d'un type d'Ã©vÃ©nement               â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_event_type(
    $event_type_id: option<record<booking_event_type>>,
    $title: option<string>,
    $slug: option<string>,
    $description: option<string>,
    $duration_min: option<int>,
    $schedule_id: option<record<booking_schedule>>,
    $location_type: option<string>,
    $location_value: option<string>,
    $buffer_before: option<int>,
    $buffer_after: option<int>,
    $min_notice_min: option<int>,
    $slot_interval: option<int>,
    $requires_confirmation: option<bool>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $event_type_id == NONE {
        THROW "Parameter 'event_type_id' is required";
    };

    LET $existing = SELECT * FROM $event_type_id;
    IF array::len($existing) == 0 {
        THROW "Event type not found";
    };

    LET $current = $existing[0];

    -- ------------------------------------------------------------------------
    -- 2. VALEURS NETTOYÃ‰ES ET VALIDATION DU SLUG (SI MODIFIÃ‰)
    -- ------------------------------------------------------------------------
    LET $clean_title = IF $title != NONE { string::trim($title) } ELSE { $current.title };
    LET $clean_slug = IF $slug != NONE { string::lowercase(string::trim($slug)) } ELSE { $current.slug };

    IF !($clean_slug ~ "^[a-z0-9-]+$") {
        THROW "Slug must contain only lowercase letters, numbers, and dashes";
    };

    -- UnicitÃ© du slug si modifiÃ©
    IF $clean_slug != $current.slug {
        LET $check = IF $current.account != NONE {
            SELECT VALUE id FROM booking_event_type WHERE account = $current.account AND slug = $clean_slug AND id != $event_type_id LIMIT 1
        } ELSE {
            SELECT VALUE id FROM booking_event_type WHERE team = $current.team AND slug = $clean_slug AND id != $event_type_id LIMIT 1
        };
        IF array::len($check) > 0 {
            THROW "An event type with this slug already exists for this owner";
        };
    };

    LET $clean_desc = IF $description != NONE { string::trim($description) } ELSE { $current.description };
    LET $clean_dur = IF $duration_min != NONE { $duration_min } ELSE { $current.duration_min };
    LET $clean_sched = IF $schedule_id != NONE { $schedule_id } ELSE { $current.schedule };
    LET $clean_loc_type = IF $location_type != NONE { string::lowercase(string::trim($location_type)) } ELSE { $current.location_type };
    LET $clean_loc_val = IF $location_value != NONE { string::trim($location_value) } ELSE { $current.location_value };
    LET $clean_buf_b = IF $buffer_before != NONE { $buffer_before } ELSE { $current.buffer_before };
    LET $clean_buf_a = IF $buffer_after != NONE { $buffer_after } ELSE { $current.buffer_after };
    LET $clean_notice = IF $min_notice_min != NONE { $min_notice_min } ELSE { $current.min_notice_min };
    LET $clean_interval = IF $slot_interval != NONE { $slot_interval } ELSE { $current.slot_interval };
    LET $clean_confirm = IF $requires_confirmation != NONE { $requires_confirmation } ELSE { $current.requires_confirmation };

    -- ------------------------------------------------------------------------
    -- 3. PERSISTANCE : MISE Ã€ JOUR DE BOOKING_EVENT_TYPE
    -- ------------------------------------------------------------------------
    UPDATE $event_type_id MERGE {
        title: $clean_title,
        slug: $clean_slug,
        description: $clean_desc,
        duration_min: $clean_dur,
        schedule: $clean_sched,
        location_type: $clean_loc_type,
        location_value: $clean_loc_val,
        buffer_before: $clean_buf_b,
        buffer_after: $clean_buf_a,
        min_notice_min: $clean_notice,
        slot_interval: $clean_interval,
        requires_confirmation: $clean_confirm,
        updated_at: time::now()
    };

    RETURN SELECT * FROM $event_type_id;
} COMMENT "Met Ã  jour l'ensemble des rÃ¨gles et informations d'un type d'Ã©vÃ©nement";
