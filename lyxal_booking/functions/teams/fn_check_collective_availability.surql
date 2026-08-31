-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_check_collective_availability                             â”‚
-- â”‚  VÃ©rifie la disponibilitÃ© simultanÃ©e de TOUS les membres Ã©ligibles       â”‚
-- â”‚  d'une Ã©quipe pour une rÃ©union collective (co-hÃ´tes/team)               â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_check_collective_availability(
    $team_id: option<record<booking_team>>,
    $start_at: option<datetime>,
    $end_at: option<datetime>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
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
    -- 2. SÃ‰LECTION DES MEMBRES Ã‰LIGIBLES (Relation Graph booking_team_member avec poids > 0)
    -- ------------------------------------------------------------------------
    LET $members = SELECT VALUE in FROM booking_team_member 
                    WHERE out = $team_id 
                      AND weight > 0;

    IF array::len($members) == 0 {
        RETURN false; -- Aucun membre disponible dans l'Ã©quipe
    };

    -- ------------------------------------------------------------------------
    -- 3. CONTRÃ”LE DE DISPONIBILITÃ‰ DE CHAQUE MEMBRE
    -- ------------------------------------------------------------------------
    FOR $member_id IN $members {
        -- A. Conflit de rÃ©servation active (booking avec host = $member_id)
        LET $booking_conflicts = SELECT VALUE id FROM booking 
                                  WHERE host = $member_id 
                                    AND status IN ['confirmed', 'pending'] 
                                    AND start_at < $end_at 
                                    AND end_at > $start_at;

        IF array::len($booking_conflicts) > 0 {
            RETURN false; -- Au moins un membre est dÃ©jÃ  occupÃ© !
        };

        -- B. Conflit d'absence approuvÃ©e (booking_time_off)
        LET $time_off_conflicts = SELECT VALUE id FROM booking_time_off 
                                   WHERE account = $member_id 
                                     AND status = 'approved' 
                                     AND start_at < $end_at 
                                     AND end_at > $start_at;

        IF array::len($time_off_conflicts) > 0 {
            RETURN false; -- Au moins un membre est en congÃ© !
        };
    };

    -- Tous les membres sont 100% libres !
    RETURN true;
} COMMENT "VÃ©rifie si tous les membres Ã©ligibles d'une Ã©quipe sont simultanÃ©ment libres pour un RDV collectif";
