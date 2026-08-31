-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_update_resource                                            │
-- │  Mise à jour des caractéristiques d'une ressource physique              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_update_resource($params: object) {
    LET $resource_id = IF $params.resource_id != NONE { $params.resource_id } ELSE { $params.id };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $resource_id == NONE {
        RETURN fn::result_error("BOOKING_RESOURCE_ID_REQUIRED", $language, { field: "resource_id" });
    };

    LET $record_id = type::record(type::string($resource_id));
    LET $res = SELECT * FROM $record_id LIMIT 1;
    IF array::len($res) == 0 {
        RETURN fn::result_error("BOOKING_RESOURCE_NOT_FOUND", $language, { resource_id: string::concat("", $record_id) });
    };

    LET $current = $res[0];
    LET $clean_name = IF $params.name != NONE AND string::len(string::trim($params.name)) > 0 { string::trim($params.name) } ELSE { $current.name };
    LET $clean_desc = IF $params.description != NONE { string::trim($params.description) } ELSE { $current.description };
    LET $clean_cap = IF $params.capacity != NONE { type::int($params.capacity) } ELSE { $current.capacity };
    LET $clean_loc = IF $params.location != NONE { string::trim($params.location) } ELSE { $current.location };
    LET $clean_en = IF $params.enabled != NONE { type::bool($params.enabled) } ELSE { $current.enabled };

    LET $updated = UPDATE ONLY $record_id MERGE {
        name: $clean_name,
        description: $clean_desc,
        capacity: $clean_cap,
        location: $clean_loc,
        enabled: $clean_en,
        updated_at: time::now()
    };

    RETURN fn::result_ok({
        id: string::concat("", $updated.id),
        name: $updated.name,
        resource_type: IF $updated.resource_type != NONE { $updated.resource_type } ELSE { "ROOM" },
        capacity: $updated.capacity,
        location: $updated.location,
        description: $updated.description,
        feed_url: $updated.feed_url,
        enabled: IF $updated.enabled != NONE { $updated.enabled } ELSE { true }
    });
} COMMENT "Met à jour le nom, la description, la capacité et la localisation d'une ressource physique";
