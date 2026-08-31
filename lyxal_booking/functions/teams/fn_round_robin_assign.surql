-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_round_robin_assign                                        â”‚
-- â”‚  SÃ©lectionne l'hÃ´te d'une Ã©quipe le plus disponible et le moins sollicitÃ©â”‚
-- â”‚  selon la stratÃ©gie d'attribution Ã©quitable Round-Robin.              â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_round_robin_assign(
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

    -- ------------------------------------------------------------------------
    -- 2. SÃ‰LECTION DES MEMBRES DE L'Ã‰QUIPE Ã‰LIGIBLES (Poids > 0)
    -- ------------------------------------------------------------------------
    LET $members = SELECT in, weight FROM booking_team_member 
                    WHERE out = $team_id 
                      AND weight > 0;

    IF array::len($members) == 0 {
        RETURN NONE; -- Aucun membre Ã©ligible dans l'Ã©quipe
    };

    -- ------------------------------------------------------------------------
    -- 3. FILTRAGE DES MEMBRES DISPONIBLES SUR LE CRÃ‰NEAU (SI LES DATES SONT FOURNIES)
    -- ------------------------------------------------------------------------
    LET $candidates = IF $start_at != NONE AND $end_at != NONE {
        LET $free_list = [];
        FOR $m IN $members {
            LET $acc = $m.in;
            -- VÃ©rifie les rÃ©servations existantes et les congÃ©s
            LET $b_conflicts = SELECT VALUE id FROM booking 
                                WHERE host = $acc 
                                  AND status IN ['confirmed', 'pending'] 
                                  AND start_at < $end_at 
                                  AND end_at > $start_at;

            LET $t_conflicts = SELECT VALUE id FROM booking_time_off 
                                WHERE account = $acc 
                                  AND status = 'approved' 
                                  AND start_at < $end_at 
                                  AND end_at > $start_at;

            IF array::len($b_conflicts) == 0 AND array::len($t_conflicts) == 0 {
                -- Compte le nombre de rÃ©servations dÃ©jÃ  attribuÃ©es Ã  cet hÃ´te (30 derniers jours)
                LET $host_load = SELECT VALUE count() FROM booking 
                                  WHERE host = $acc 
                                    AND created_at >= time::now() - 30d;
                LET $load_val = IF array::len($host_load) > 0 { $host_load[0] } ELSE { 0 };
                
                -- Ajustement du score selon le poids (weight)
                LET $score = $load_val / IF $m.weight > 0 { $m.weight } ELSE { 1 };
                
                $free_list.push({
                    account: $acc,
                    weight: $m.weight,
                    load: $load_val,
                    score: $score
                });
            };
        };
        $free_list
    } ELSE {
        $members
    };

    IF array::len($candidates) == 0 {
        RETURN NONE; -- Aucun membre disponible sur ce crÃ©neau
    };

    -- ------------------------------------------------------------------------
    -- 4. TRI PAR SCORE DE CHARGE (Le membre le moins sollicitÃ© en premier)
    -- ------------------------------------------------------------------------
    LET $sorted = array::sort::asc($candidates);
    RETURN $sorted[0].account;
} COMMENT "SÃ©lectionne l'hÃ´te idÃ©al d'une Ã©quipe selon la stratÃ©gie d'attribution Round-Robin pondÃ©rÃ©e";
