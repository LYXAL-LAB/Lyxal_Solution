-- ============================================================================
-- LYXAL OS — BOOKING RESOURCES
-- ============================================================================
-- Fichier  : functions/resources/fn_get_resource.surql
-- Fonction : fn::booking_get_resource
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_resource($params: object) {
    LET $resource_id = $params.resource_id;

    IF $resource_id IS NONE {
        THROW "BOOKING_INVALID_PARAMS: resource_id est obligatoire";
    };

    LET $res = SELECT * FROM $resource_id LIMIT 1;
    IF array::len($res) = 0 {
        THROW "BOOKING_RESOURCE_NOT_FOUND: Ressource introuvable";
    };

    LET $r = $res[0];
    RETURN {
        id: string::concat("", $r.id),
        name: $r.name,
        resource_type: IF $r.resource_type != NONE { $r.resource_type } ELSE { "ROOM" },
        capacity: $r.capacity,
        location: $r.location,
        description: $r.description,
        feed_url: $r.feed_url,
        enabled: IF $r.enabled != NONE { $r.enabled } ELSE { true }
    };
};
