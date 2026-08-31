-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_check_frequency_limit                                     â”‚
-- â”‚  VÃ©rifie si la limite/quota maximal de rÃ©servations par jour, semaine   â”‚
-- â”‚  ou mois (global ou par hÃ´te) n'est pas dÃ©passÃ©.                       â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_check_frequency_limit(
    $event_type_id: option<record<booking_event_type>>,
    $proposed_start: option<datetime>,
    $host_id: option<record<booking_account>>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES (Erreurs explicites)
    -- ------------------------------------------------------------------------
    IF $event_type_id == NONE {
        THROW "Parameter 'event_type_id' is required";
    };
    IF $proposed_start == NONE {
        THROW "Parameter 'proposed_start' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. RÃ‰CUPÃ‰RATION DES LIMITES CONFIGURÃ‰ES POUR LE TYPE D'Ã‰VÃ‰NEMENT
    -- ------------------------------------------------------------------------
    LET $limits = SELECT * FROM booking_frequency_limit WHERE event_type = $event_type_id;
    IF array::len($limits) == 0 {
        RETURN false; -- Aucune limite configurÃ©e -> Ne dÃ©passe pas la limite
    };

    -- ------------------------------------------------------------------------
    -- 3. INTERROGATION DES PLAGES DE QUOTAS (DAY / WEEK / MONTH)
    -- ------------------------------------------------------------------------
    FOR $limit IN $limits {
        LET $period = $limit.limit_period;
        LET $max_bookings = $limit.max_bookings;

        -- DÃ©finition de la plage temporelle selon la pÃ©riode
        LET $range_start = IF $period == 'day' {
            time::floor($proposed_start, 1d)
        } ELSE IF $period == 'week' {
            time::floor($proposed_start, 1w)
        } ELSE {
            time::floor($proposed_start, 30d)
        };

        LET $range_end = IF $period == 'day' {
            $range_start + 1d
        } ELSE IF $period == 'week' {
            $range_start + 1w
        } ELSE {
            $range_start + 30d
        };

        -- Compte les rÃ©servations actives (confirmed ou pending) sur la pÃ©riode
        LET $count_query = IF $host_id != NONE {
            SELECT VALUE count() FROM booking 
             WHERE event_type = $event_type_id 
               AND host = $host_id 
               AND status IN ['confirmed', 'pending'] 
               AND start_at >= $range_start 
               AND start_at < $range_end
        } ELSE {
            SELECT VALUE count() FROM booking 
             WHERE event_type = $event_type_id 
               AND status IN ['confirmed', 'pending'] 
               AND start_at >= $range_start 
               AND start_at < $range_end
        };

        LET $count = IF array::len($count_query) > 0 { $count_query[0] } ELSE { 0 };

        -- Si le quota est atteint ou dÃ©passÃ©
        IF $count >= $max_bookings {
            RETURN true; -- Limite dÃ©passÃ©e !
        };
    };

    -- Quotas respectÃ©s
    RETURN false;
} COMMENT "VÃ©rifie si la limite maximale de rÃ©servations par jour, semaine ou mois est dÃ©passÃ©e (Renvoie true si dÃ©passÃ©)";
