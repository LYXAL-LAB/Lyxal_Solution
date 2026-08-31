-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_dashboard_stats                                       â”‚
-- â”‚  RÃ©cupÃ¨re les statistiques clÃ©s du tableau de bord d'un hÃ´te/admin      â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_dashboard_stats(
    $account_id: option<record<booking_account>>,
    $is_admin: option<bool>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    LET $admin_flag = IF $is_admin != NONE { $is_admin } ELSE { false };

    IF $admin_flag == false AND $account_id == NONE {
        THROW "Parameter 'account_id' is required for non-admin users";
    };

    -- ------------------------------------------------------------------------
    -- 2. CALCUL DES COMPTEURS SUR LE SCHÃ‰MA V1
    -- ------------------------------------------------------------------------
    -- A. Nombre de types d'Ã©vÃ©nements personnels
    LET $et_res = IF $account_id != NONE {
        SELECT VALUE count() FROM booking_event_type WHERE account = $account_id AND team = NONE
    } ELSE {
        [0]
    };
    LET $et_count = IF array::len($et_res) > 0 { $et_res[0] } ELSE { 0 };

    -- B. Nombre de rÃ©servations Ã  venir
    LET $up_res = IF $account_id != NONE {
        SELECT VALUE count() FROM booking WHERE host = $account_id AND status = 'confirmed' AND start_at >= time::now()
    } ELSE {
        SELECT VALUE count() FROM booking WHERE status = 'confirmed' AND start_at >= time::now()
    };
    LET $upcoming_count = IF array::len($up_res) > 0 { $up_res[0] } ELSE { 0 };

    -- C. Nombre de sources CalDAV/Google rattachÃ©es
    LET $src_res = IF $account_id != NONE {
        SELECT VALUE count() FROM booking_caldav_source WHERE account = $account_id
    } ELSE {
        SELECT VALUE count() FROM booking_caldav_source
    };
    LET $source_count = IF array::len($src_res) > 0 { $src_res[0] } ELSE { 0 };

    -- D. Nombre d'Ã©quipes (toutes pour admin, rattachÃ©es via Graph pour utilisateur)
    LET $t_res = IF $admin_flag {
        SELECT VALUE count() FROM booking_team
    } ELSE {
        SELECT VALUE count() FROM booking_team_member WHERE in = $account_id
    };
    LET $team_count = IF array::len($t_res) > 0 { $t_res[0] } ELSE { 0 };

    -- ------------------------------------------------------------------------
    -- 3. RETOUR DE LA SYNTHÃˆSE DES STATISTIQUES
    -- ------------------------------------------------------------------------
    RETURN {
        event_type_count: $et_count,
        upcoming_count: $upcoming_count,
        source_count: $source_count,
        team_count: $team_count
    };
} COMMENT "RÃ©cupÃ¨re les mÃ©triques globales du tableau de bord (Ã©vÃ©nements, rendez-vous Ã  venir, calendriers distants, Ã©quipes)";
