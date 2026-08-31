-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_set_resource_enabled                                       │
-- │  Active ou désactive une ressource physique                             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_set_resource_enabled($params: object) {
    LET $resource_id = IF $params.resource_id != NONE { $params.resource_id } ELSE { $params.id };
    LET $enabled = type::bool($params.enabled);
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $resource_id == NONE {
        RETURN fn::result_error("BOOKING_RESOURCE_ID_REQUIRED", $language, { field: "resource_id" });
    };

    LET $record_id = type::record(type::string($resource_id));

    UPDATE $record_id SET enabled = $enabled, updated_at = time::now();

    RETURN fn::result_ok({
        resource_id: $record_id,
        enabled: $enabled,
        updated: true
    });
} COMMENT "Active ou désactive une ressource physique réservable";
