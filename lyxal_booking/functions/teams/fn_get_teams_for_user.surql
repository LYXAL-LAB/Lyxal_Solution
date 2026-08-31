-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_teams_for_user                                        â”‚
-- â”‚  RÃ©cupÃ¨re les Ã©quipes associÃ©es Ã  un compte hÃ´te (ou toutes si admin)    â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_teams_for_user(
    $account_id: option<record<booking_account>>,
    $is_admin: option<bool>
) {
    -- ------------------------------------------------------------------------
    -- 1. VALEUR PAR DÃ‰FAUT DU DRAPEAU ADMIN
    -- ------------------------------------------------------------------------
    LET $admin_flag = IF $is_admin != NONE { $is_admin } ELSE { false };

    -- ------------------------------------------------------------------------
    -- 2. VÃ‰RIFICATION DU PARAMÃˆTRE SI NON-ADMIN
    -- ------------------------------------------------------------------------
    IF $admin_flag == false AND $account_id == NONE {
        THROW "Parameter 'account_id' is required for non-admin users";
    };

    -- ------------------------------------------------------------------------
    -- 3. RECHERCHE DES Ã‰QUIPES (Graph relation booking_team_member)
    -- ------------------------------------------------------------------------
    RETURN IF $admin_flag {
        -- Si administrateur global : retourne toutes les Ã©quipes avec le nombre de membres
        SELECT *, 
               (SELECT VALUE count() FROM booking_team_member WHERE out = $parent.id) AS member_count 
          FROM booking_team 
         ORDER BY name
    } ELSE {
        -- Si utilisateur standard : traverse la relation graph booking_team_member (in = $account_id -> out)
        SELECT out.id AS id, 
               out.name AS name, 
               out.slug AS slug, 
               out.description AS description, 
               out.visibility AS visibility, 
               out.logo_url AS logo_url, 
               out.invite_token AS invite_token, 
               role AS user_role,
               (SELECT VALUE count() FROM booking_team_member WHERE out = $parent.out) AS member_count 
          FROM booking_team_member 
         WHERE in = $account_id 
         ORDER BY out.name
    };
} COMMENT "RÃ©cupÃ¨re la liste des Ã©quipes d'un utilisateur ou toutes les Ã©quipes si administrateur";
