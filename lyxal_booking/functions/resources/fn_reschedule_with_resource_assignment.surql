-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_reschedule_with_resource_assignment                        │
-- │  Report atomique avec validation de statut et réaffectation ressource   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_reschedule_with_resource_assignment($params: object) {
    LET $booking_id = $params.booking_id;
    LET $expected_start_at = $params.expected_start_at;
    LET $expected_end_at = $params.expected_end_at;
    LET $expected_updated_at = $params.expected_updated_at;
    LET $new_start_at = $params.new_start_at;
    LET $new_end_at = $params.new_end_at;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $booking_id == NONE OR $new_start_at == NONE OR $new_end_at == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "booking_id, new_start_at or new_end_at" });
    };

    LET $b = SELECT id, event_type, status, start_at, end_at, updated_at, assigned_resource_id FROM ONLY $booking_id;
    IF $b == NONE {
        RETURN fn::result_error("BOOKING_NOT_FOUND", $language, { record_id: $booking_id });
    };

    -- Contrôle du statut compatible avec un report
    IF $b.status != NONE AND string::lowercase($b.status) IN ['cancelled', 'rejected'] {
        RETURN fn::result_error("BOOKING_STATUS_INVALID_FOR_RESCHEDULE", $language, { status: $b.status });
    };

    -- Contrôle de verrouillage optimiste sur les anciennes dates si fournies
    IF $expected_start_at != NONE AND $b.start_at != $expected_start_at {
        RETURN fn::result_error("BOOKING_CONCURRENT_MODIFICATION", $language, { field: "start_at" });
    };

    -- Contrôle de verrouillage optimiste sur updated_at si fourni
    IF $expected_updated_at != NONE AND $b.updated_at != NONE AND $b.updated_at != $expected_updated_at {
        RETURN fn::result_error("BOOKING_CONCURRENT_MODIFICATION", $language, { field: "updated_at" });
    };

    LET $event_type_id = $b.event_type;
    LET $assigned_resource = $b.assigned_resource_id;

    IF $event_type_id != NONE {
        LET $et = SELECT id, resource_scheduling_mode FROM ONLY $event_type_id;
        LET $mode = IF $et != NONE AND $et.resource_scheduling_mode != NONE { $et.resource_scheduling_mode } ELSE { "all" };

        LET $resources = SELECT VALUE id FROM booking_resource
            WHERE id IN (
                SELECT VALUE out FROM booking_event_type_resource WHERE in == $event_type_id
            ) AND (enabled == NONE OR enabled == true);

        IF count($resources) > 0 {
            -- Exclusion explicite de la réservation en cours du contrôle d'indisponibilité
            LET $free_resources = SELECT VALUE id FROM $resources WHERE id NOT IN (
                SELECT VALUE assigned_resource_id FROM booking
                    WHERE assigned_resource_id != NONE
                      AND id != $booking_id
                      AND (status == NONE OR string::lowercase(status) NOT IN ['cancelled', 'rejected'])
                      AND ((start_at < $new_end_at AND end_at > $new_start_at))
            );

            IF $mode == "all" AND count($free_resources) < count($resources) {
                RETURN fn::result_error("BOOKING_RESOURCE_BUSY", $language, { mode: "all" });
            };

            IF count($free_resources) == 0 {
                RETURN fn::result_error("BOOKING_RESOURCE_BUSY", $language, { mode: $mode });
            };

            $assigned_resource = $free_resources[0];
        };
    };

    LET $updated = UPDATE ONLY $booking_id SET
        start_at = $new_start_at,
        end_at = $new_end_at,
        assigned_resource_id = $assigned_resource,
        updated_at = time::now();

    RETURN fn::result_ok({
        booking_id: $updated.id,
        assigned_resource_id: $assigned_resource,
        start_at: $new_start_at,
        end_at: $new_end_at
    });
} COMMENT "Report atomique de réservation avec verrouillage optimiste sur updated_at et réaffectation ressource";
