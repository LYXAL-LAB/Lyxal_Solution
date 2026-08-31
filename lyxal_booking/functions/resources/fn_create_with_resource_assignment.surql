-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_create_with_resource_assignment                           │
-- │  Création de réservation avec DTO canonique et affectation de ressource│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_create_with_resource_assignment($params: object) {
    LET $event_type_id = $params.event_type_id;
    LET $start_at = $params.start_at;
    LET $end_at = $params.end_at;
    LET $customer_name = $params.customer_name;
    LET $customer_email = $params.customer_email;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $event_type_id == NONE OR $start_at == NONE OR $end_at == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "event_type_id, start_at or end_at" });
    };

    LET $et = SELECT id, resource_scheduling_mode FROM ONLY $event_type_id;
    IF $et == NONE {
        RETURN fn::result_error("BOOKING_NOT_FOUND", $language, { record_id: $event_type_id });
    };

    LET $mode = IF $et.resource_scheduling_mode != NONE { $et.resource_scheduling_mode } ELSE { "all" };

    -- Recherche des ressources rattachées
    LET $resources = SELECT VALUE id FROM booking_resource
        WHERE id IN (
            SELECT VALUE out FROM booking_event_type_resource WHERE in == $event_type_id
        ) AND (enabled == NONE OR enabled == true);

    LET $assigned_resource = NONE;

    IF count($resources) > 0 {
        -- Vérification de disponibilité des ressources
        LET $free_resources = SELECT VALUE id FROM $resources WHERE id NOT IN (
            SELECT VALUE assigned_resource_id FROM booking
                WHERE assigned_resource_id != NONE
                  AND (status == NONE OR string::lowercase(status) NOT IN ['cancelled', 'rejected'])
                  AND ((start_at < $end_at AND end_at > $start_at))
        );

        IF $mode == "all" AND count($free_resources) < count($resources) {
            RETURN fn::result_error("BOOKING_RESOURCE_BUSY", $language, { mode: "all" });
        };

        IF count($free_resources) == 0 {
            RETURN fn::result_error("BOOKING_RESOURCE_BUSY", $language, { mode: $mode });
        };

        -- Sélection de la ressource la moins chargée en mode round_robin
        $assigned_resource = $free_resources[0];
    };

    -- Création atomique du record booking avec l'ensemble des champs canoniques
    LET $created = CREATE ONLY booking CONTENT {
        event_type: $event_type_id,
        uid: $params.uid,
        start_at: $start_at,
        end_at: $end_at,
        customer_name: $customer_name,
        customer_email: $customer_email,
        customer_time_zone: $params.customer_time_zone,
        customer_notes: $params.customer_notes,
        location: $params.location,
        additional_notes: $params.additional_notes,
        cancel_token: $params.cancel_token,
        reschedule_token: $params.reschedule_token,
        assigned_user_id: $params.assigned_user_id,
        assigned_resource_id: $assigned_resource,
        status: IF $params.status != NONE { $params.status } ELSE { "confirmed" },
        created_at: time::now(),
        updated_at: time::now()
    };

    RETURN fn::result_ok({
        booking_id: $created.id,
        assigned_resource_id: $assigned_resource,
        scheduling_mode: $mode
    });
} COMMENT "Création atomique de réservation canonique complète avec sélection et verrouillage de ressource";
