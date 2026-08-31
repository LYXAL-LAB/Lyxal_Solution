-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_event_type_resources                                  │
-- │  Lecture des ressources associées à un type d'événement et du mode    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_event_type_resources($params: object) {
    LET $event_type_id = $params.event_type_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $event_type_id == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "event_type_id" });
    };

    LET $et = SELECT id, resource_scheduling_mode FROM ONLY $event_type_id;
    IF $et == NONE {
        RETURN fn::result_error("BOOKING_NOT_FOUND", $language, { record_id: $event_type_id });
    };

    LET $resources = SELECT id, name FROM booking_resource
        WHERE id IN (
            SELECT VALUE out FROM booking_event_type_resource WHERE in == $event_type_id
        ) AND (enabled == NONE OR enabled == true);

    RETURN fn::result_ok({
        event_type_id: $et.id,
        scheduling_mode: IF $et.resource_scheduling_mode != NONE { $et.resource_scheduling_mode } ELSE { "all" },
        resources: $resources
    });
} COMMENT "Lecture des ressources rattachées à un type d'événement et du mode de planification";
