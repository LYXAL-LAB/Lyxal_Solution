-- ============================================================================
-- LYXAL OS — BOOKING RESOURCES
-- ============================================================================
-- Fichier  : functions/resources/fn_list_resources.surql
-- Fonction : fn::booking_list_resources
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_list_resources($params: object) {
    LET $resources = SELECT * FROM booking_resource ORDER BY created_at DESC;

    RETURN array::map($resources, |$r| {
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
    });
};
