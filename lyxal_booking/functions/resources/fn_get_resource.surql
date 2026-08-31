-- ============================================================================
-- LYXAL OS — BOOKING RESOURCES
-- ============================================================================
-- Fichier  : functions/resources/fn_get_resource.surql
-- Fonction : fn::booking_get_resource
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_resource($params: object) {
    LET $resource_id = $params.resource_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $resource_id == NONE {
        RETURN fn::result_error("BOOKING_RESOURCE_ID_REQUIRED", $language, { field: "resource_id" });
    };

    LET $record_id = type::record(type::string($resource_id));
    LET $res = SELECT * FROM $record_id LIMIT 1;
    IF array::len($res) == 0 {
        RETURN fn::result_error("BOOKING_RESOURCE_NOT_FOUND", $language, { resource_id: string::concat("", $record_id) });
    };

    LET $r = $res[0];
    RETURN fn::result_ok({
        id: $r.id,
        name: $r.name,
        resource_type: IF $r.resource_type != NONE { $r.resource_type } ELSE { "ROOM" },
        capacity: $r.capacity,
        location: $r.location,
        description: $r.description,
        feed_url: $r.feed_url,
        enabled: IF $r.enabled != NONE { $r.enabled } ELSE { true }
    });
} COMMENT "Récupère les détails d'une ressource physique par son identifiant";
