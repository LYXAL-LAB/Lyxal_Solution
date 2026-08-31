-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_allocate_resource                                         â”‚
-- â”‚  Affecte et verrouille une ressource physique pour un rendez-vous      â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_allocate_resource(
    $resource_id: option<record<booking_resource>>,
    $booking_id: option<record<booking>>,
    $quantity: option<int>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $resource_id == NONE {
        THROW "Parameter 'resource_id' is required";
    };
    IF $booking_id == NONE {
        THROW "Parameter 'booking_id' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. RECUPERATION DU RENDEZ-VOUS ET VERIFICATION DE DISPONIBILITE
    -- ------------------------------------------------------------------------
    LET $b = SELECT start_at, end_at FROM $booking_id;
    IF array::len($b) == 0 {
        THROW "Booking not found";
    };

    LET $start_at = $b[0].start_at;
    LET $end_at = $b[0].end_at;

    LET $is_free = fn::booking_check_resource_availability($resource_id, $start_at, $end_at);
    IF $is_free == false {
        THROW "Resource is already allocated for this time slot";
    };

    LET $clean_qty = IF $quantity != NONE AND $quantity > 0 { $quantity } ELSE { 1 };

    -- ------------------------------------------------------------------------
    -- 3. CRÃ‰ATION DE LA RELATION GRAPH (booking_resource -> booking_resource_allocation -> booking)
    -- ------------------------------------------------------------------------
    LET $rel = RELATE $resource_id->booking_resource_allocation->$booking_id CONTENT {
        quantity: $clean_qty,
        created_at: time::now()
    };

    RETURN $rel;
} COMMENT "Affecte et rÃ©serve une salle ou un Ã©quipement physique pour un rendez-vous via la relation Graph";
