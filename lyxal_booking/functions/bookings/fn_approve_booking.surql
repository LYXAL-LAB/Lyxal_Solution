-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_approve_booking                                            │
-- │  Approbation canonique d'une réservation en attente                      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_approve_booking($params: object) {
    LET $id_param = IF $params.booking_id != NONE { $params.booking_id } ELSE IF $params.id != NONE { $params.id } ELSE { $params.token };
    IF $id_param == NONE {
        RETURN fn::result_error("BOOKING_ID_OR_TOKEN_REQUIRED", "fr", "Paramètre booking_id ou token obligatoire");
    };

    LET $token_val = string::trim(type::string($id_param));
    LET $records = SELECT * FROM booking 
                   WHERE id = type::record($token_val) 
                      OR id = $token_val 
                      OR confirm_token = $token_val 
                      OR token = $token_val 
                   LIMIT 1;

    IF array::len($records) == 0 {
        RETURN fn::result_error("BOOKING_NOT_FOUND", "fr", "Réservation introuvable");
    };

    LET $b = $records[0];

    IF $b.status != 'pending' {
        RETURN fn::result_error("BOOKING_NOT_PENDING", "fr", "Seule une réservation en attente (pending) peut être approuvée");
    };

    LET $resource_id = IF $params.assigned_resource_id != NONE { type::record(string::trim(type::string($params.assigned_resource_id))) } ELSE { $b.assigned_resource_id };

    UPDATE $b.id SET 
        status = 'confirmed',
        assigned_resource_id = $resource_id,
        confirmed_at = time::now(),
        updated_at = time::now();

    RETURN fn::result_ok({
        id: string::trim(type::string($b.id)),
        booking_id: string::trim(type::string($b.id)),
        event_type_id: string::trim(type::string($b.event_type)),
        start_at: string::trim(type::string($b.start_at)),
        end_at: string::trim(type::string($b.end_at)),
        status: 'confirmed',
        assigned_resource_id: IF $resource_id != NONE { string::trim(type::string($resource_id)) } ELSE { NONE },
        guest_name: $b.guest_name,
        guest_email: $b.guest_email,
        confirmed_at: time::now()
    });
} COMMENT "Approuve une réservation en attente et confirme son statut de manière atomique";
