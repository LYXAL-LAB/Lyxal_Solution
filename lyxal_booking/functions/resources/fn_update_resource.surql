-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_update_resource                                            â”‚
-- â”‚  Mise Ã  jour des caractÃ©ristiques d'une ressource physique              â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_update_resource(
    $resource_id: option<record<booking_resource>>,
    $name: option<string>,
    $description: option<string>,
    $capacity: option<int>,
    $location: option<string>,
    $enabled: option<bool>
) {
    IF $resource_id == NONE {
        THROW "Parameter 'resource_id' is required";
    };

    LET $res = SELECT * FROM $resource_id;
    IF array::len($res) == 0 {
        THROW "Resource not found";
    };

    LET $current = $res[0];

    LET $clean_name = IF $name != NONE AND string::len(string::trim($name)) > 0 { string::trim($name) } ELSE { $current.name };
    LET $clean_desc = IF $description != NONE { string::trim($description) } ELSE { $current.description };
    LET $clean_cap = IF $capacity != NONE { $capacity } ELSE { $current.capacity };
    LET $clean_loc = IF $location != NONE { string::trim($location) } ELSE { $current.location };
    LET $clean_en = IF $enabled != NONE { $enabled } ELSE { $current.enabled };

    UPDATE $resource_id MERGE {
        name: $clean_name,
        description: $clean_desc,
        capacity: $clean_cap,
        location: $clean_loc,
        enabled: $clean_en,
        updated_at: time::now()
    };

    RETURN SELECT * FROM $resource_id;
} COMMENT "Met Ã  jour le nom, la description, la capacitÃ© et la localisation d'une ressource physique";
