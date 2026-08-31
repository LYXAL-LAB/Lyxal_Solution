-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_create_resource                                            │
-- │  Création d'une ressource physique (salle de réunion, équipement)      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_create_resource($params: object) {
    LET $name = $params.name;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        RETURN fn::result_error("BOOKING_RESOURCE_NAME_REQUIRED", $language, { field: "name" });
    };

    LET $clean_name = string::trim($name);
    LET $clean_desc = IF $params.description != NONE { string::trim($params.description) } ELSE { NONE };
    LET $clean_cap = IF $params.capacity != NONE AND type::int($params.capacity) > 0 { type::int($params.capacity) } ELSE { NONE };
    LET $clean_loc = IF $params.location != NONE { string::trim($params.location) } ELSE { NONE };
    LET $custom_id = $params.id;

    IF $custom_id != NONE {
        LET $res = UPSERT ONLY $custom_id CONTENT {
            name: $clean_name,
            description: $clean_desc,
            capacity: $clean_cap,
            location: $clean_loc,
            enabled: true,
            created_at: time::now()
        };
        RETURN fn::result_ok({
            id: $res.id,
            created: true
        });
    };

    LET $res = CREATE ONLY booking_resource CONTENT {
        name: $clean_name,
        description: $clean_desc,
        capacity: $clean_cap,
        location: $clean_loc,
        enabled: true,
        created_at: time::now()
    };

    RETURN fn::result_ok({
        id: $res.id,
        created: true
    });
} COMMENT "Enregistre une nouvelle ressource physique réservable (salle ou équipement)";
