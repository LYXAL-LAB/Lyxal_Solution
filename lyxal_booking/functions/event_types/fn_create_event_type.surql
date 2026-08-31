-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_create_event_type                                          │
-- │  Crée un nouveau type d'événement (individuel ou d'équipe)               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_create_event_type($params: object) {
    LET $account_id = IF $params.account_id != NONE { type::record(type::string($params.account_id)) } ELSE { NONE };
    LET $team_id = IF $params.team_id != NONE { type::record(type::string($params.team_id)) } ELSE { NONE };
    LET $title = $params.title;
    LET $slug = $params.slug;
    LET $duration_min = type::int($params.duration_min);
    LET $custom_id = IF $params.id != NONE { type::record(type::string($params.id)) } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $title == NONE OR string::len(string::trim($title)) == 0 {
        RETURN fn::result_error("BOOKING_EVENT_TYPE_TITLE_REQUIRED", $language, { field: "title" });
    };
    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        RETURN fn::result_error("BOOKING_EVENT_TYPE_SLUG_REQUIRED", $language, { field: "slug" });
    };
    IF $duration_min == NONE OR $duration_min <= 0 {
        RETURN fn::result_error("BOOKING_EVENT_TYPE_DURATION_INVALID", $language, { field: "duration_min" });
    };

    LET $clean_title = string::trim($title);
    LET $clean_slug = string::lowercase(string::trim($slug));

    IF string::len($clean_slug) == 0 {
        RETURN fn::result_error("BOOKING_EVENT_TYPE_SLUG_REQUIRED", $language, { field: "slug" });
    };

    LET $loc_type = IF $params.location_type != NONE { string::lowercase(string::trim($params.location_type)) } ELSE { 'link' };
    LET $loc_val = IF $params.location_value != NONE { string::trim($params.location_value) } ELSE { NONE };

    IF $custom_id != NONE {
        LET $res = UPSERT ONLY $custom_id CONTENT {
            account: $account_id,
            team: $team_id,
            slug: $clean_slug,
            title: $clean_title,
            duration_min: $duration_min,
            location_type: $loc_type,
            location_value: $loc_val,
            enabled: true,
            created_at: time::now()
        };
        RETURN fn::result_ok({
            id: $res.id,
            created: true
        });
    };

    LET $res = CREATE ONLY booking_event_type CONTENT {
        account: $account_id,
        team: $team_id,
        slug: $clean_slug,
        title: $clean_title,
        duration_min: $duration_min,
        location_type: $loc_type,
        location_value: $loc_val,
        enabled: true,
        created_at: time::now()
    };

    RETURN fn::result_ok({
        id: $res.id,
        created: true
    });
} COMMENT "Crée un nouveau type d'événement / lien de réservation (individuel ou d'équipe)";
