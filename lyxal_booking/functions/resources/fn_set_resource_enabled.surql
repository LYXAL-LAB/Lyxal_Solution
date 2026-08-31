-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_set_resource_enabled                                       │
-- │  Active ou désactive une ressource physique                             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_set_resource_enabled($params: object) {
    LET $resource_id = IF $params.resource_id != NONE { $params.resource_id } ELSE { $params.id };
    LET $enabled = type::bool($params.enabled);

    IF $resource_id == NONE {
        THROW "Parameter 'resource_id' is required";
    };

    LET $record_id = type::record(type::string($resource_id));

    UPDATE $record_id SET enabled = $enabled, updated_at = time::now();

    RETURN {
        resource_id: $record_id,
        enabled: $enabled,
        updated: true
    };
} COMMENT "Active ou désactive une ressource physique réservable";
