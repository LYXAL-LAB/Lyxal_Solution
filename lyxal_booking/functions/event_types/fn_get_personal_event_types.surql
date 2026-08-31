-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_personal_event_types                                  │
-- │  Récupère les types d'événements individuels d'un compte hôte            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_personal_event_types(
    $account_id: option<record<booking_account>>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    RETURN SELECT id, 
                  slug, 
                  title, 
                  duration_min, 
                  enabled, 
                  requires_confirmation, 
                  location_type,
                  location_value,
                  (SELECT VALUE count() FROM booking WHERE event_type = $parent.id AND status IN ['confirmed', 'pending']) AS active_bookings,
                  created_at
             FROM booking_event_type 
            WHERE account = $account_id 
              AND team = NONE 
            ORDER BY created_at ASC;
};
