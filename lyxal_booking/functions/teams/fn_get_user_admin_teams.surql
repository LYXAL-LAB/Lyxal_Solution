-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_user_admin_teams                                      â”‚
-- â”‚  RÃ©cupÃ¨re la liste des identifiants d'Ã©quipes administrÃ©es par un compte â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_user_admin_teams(
    $account_id: option<record<booking_account>>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DU PARAMÃˆTRE OBLIGATOIRE
    -- ------------------------------------------------------------------------
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. RECHERCHE VIA LA RELATION GRAPH (RÃ´les admin ou owner)
    -- ------------------------------------------------------------------------
    RETURN SELECT VALUE out FROM booking_team_member 
            WHERE in = $account_id 
              AND role IN ['admin', 'owner'];
} COMMENT "Renvoie la liste des IDs d'Ã©quipes dont l'utilisateur est administrateur ou propriÃ©taire";
