-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_create_resource                                            │
-- │  Création d'une ressource physique (salle de réunion, équipement)      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_create_resource($params: object) {
    LET $name = $params.name;
    IF $name == NONE OR string::len(string::trim($name)) == 0 {
        THROW "Parameter 'name' is required";
    };

    LET $clean_name = string::trim($name);
    LET $clean_desc = IF $params.description != NONE { string::trim($params.description) } ELSE { NONE };
    LET $clean_cap = IF $params.capacity != NONE AND type::int($params.capacity) > 0 { type::int($params.capacity) } ELSE { NONE };
    LET $clean_loc = IF $params.location != NONE { string::trim($params.location) } ELSE { NONE };
    LET $custom_id = $params.id;

    LET $created = IF $custom_id != NONE {
        UPSERT ONLY $custom_id CONTENT {
            name: $clean_name,
            description: $clean_desc,
            capacity: $clean_cap,
            location: $clean_loc,
            enabled: true,
            created_at: time::now()
        }
    } ELSE {
        CREATE ONLY booking_resource CONTENT {
            name: $clean_name,
            description: $clean_desc,
            capacity: $clean_cap,
            location: $clean_loc,
            enabled: true,
            created_at: time::now()
        }
    };

    RETURN {
        id: $created.id,
        created: true
    };
} COMMENT "Enregistre une nouvelle ressource physique réservable (salle ou équipement)";
