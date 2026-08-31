-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_check_resource_availability                               â”‚
-- â”‚  VÃ©rifie la disponibilitÃ© d'une ressource physique pour un crÃ©neau      â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_check_resource_availability(
    $resource_id: option<record<booking_resource>>,
    $start_at: option<datetime>,
    $end_at: option<datetime>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $resource_id == NONE {
        THROW "Parameter 'resource_id' is required";
    };
    IF $start_at == NONE {
        THROW "Parameter 'start_at' is required";
    };
    IF $end_at == NONE {
        THROW "Parameter 'end_at' is required";
    };
    IF $end_at <= $start_at {
        THROW "Parameter 'end_at' must be strictly after 'start_at'";
    };

    -- ------------------------------------------------------------------------
    -- 2. RECHERCHE DE CONFLIT SUR LA RELATION GRAPH BOOKING_RESOURCE_ALLOCATION
    -- ------------------------------------------------------------------------
    LET $conflicts = SELECT VALUE id FROM booking_resource_allocation 
                      WHERE in = $resource_id 
                        AND out.status IN ['confirmed', 'pending'] 
                        AND out.start_at < $end_at 
                        AND out.end_at > $start_at;
                        
    IF array::len($conflicts) > 0 {
        RETURN false; -- Ressource dÃ©jÃ  rÃ©servÃ©e sur ce crÃ©neau !
    } ELSE {
        RETURN true;  -- Ressource disponible !
    };
} COMMENT "VÃ©rifie si une salle ou un Ã©quipement physique est disponible sans conflit de rÃ©servation";
