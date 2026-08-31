-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_create_event_type                                          │
-- │  Crée un nouveau type d'événement (individuel ou d'équipe)               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_create_event_type($params: object) {
    LET $account_id = $params.account_id;
    LET $team_id = $params.team_id;
    LET $title = $params.title;
    LET $slug = $params.slug;
    LET $duration_min = type::int($params.duration_min);
    LET $custom_id = $params.id;

    IF $title == NONE OR string::len(string::trim($title)) == 0 {
        THROW "Parameter 'title' is required";
    };
    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        THROW "Parameter 'slug' is required";
    };
    IF $duration_min == NONE OR $duration_min <= 0 {
        THROW "Parameter 'duration_min' is required and must be > 0";
    };

    LET $clean_title = string::trim($title);
    LET $clean_slug = string::lowercase(string::trim($slug));

    IF !($clean_slug ~ "^[a-z0-9-]+$") {
        THROW "Slug must contain only lowercase letters, numbers, and dashes";
    };

    LET $loc_type = IF $params.location_type != NONE { string::lowercase(string::trim($params.location_type)) } ELSE { 'link' };
    LET $loc_val = IF $params.location_value != NONE { string::trim($params.location_value) } ELSE { NONE };

    LET $created = IF $custom_id != NONE {
        UPSERT ONLY $custom_id CONTENT {
            account: $account_id,
            team: $team_id,
            slug: $clean_slug,
            title: $clean_title,
            duration_min: $duration_min,
            location_type: $loc_type,
            location_value: $loc_val,
            enabled: true,
            created_at: time::now()
        }
    } ELSE {
        CREATE ONLY booking_event_type CONTENT {
            account: $account_id,
            team: $team_id,
            slug: $clean_slug,
            title: $clean_title,
            duration_min: $duration_min,
            location_type: $loc_type,
            location_value: $loc_val,
            enabled: true,
            created_at: time::now()
        }
    };

    RETURN {
        id: $created.id,
        created: true
    };
} COMMENT "Crée un nouveau type d'événement / lien de réservation (individuel ou d'équipe)";
