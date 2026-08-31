-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_team_members                                          â”‚
-- â”‚  Retourne la liste ordonnÃ©e des membres actifs d'une Ã©quipe             â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_team_members(
    $team_id: option<record<booking_team>>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DU PARAMÃˆTRE OBLIGATOIRE
    -- ------------------------------------------------------------------------
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. RECHERCHE VIA LA RELATION GRAPH BOOKING_TEAM_MEMBER
    -- ------------------------------------------------------------------------
    RETURN SELECT in.id AS account_id, 
                  in.name AS account_name, 
                  in.email AS account_email, 
                  role, 
                  weight, 
                  source, 
                  created_at 
             FROM booking_team_member 
            WHERE out = $team_id 
            ORDER BY weight DESC, role ASC;
} COMMENT "Retourne la liste ordonnÃ©e des membres d'une Ã©quipe avec leurs dÃ©tails et coefficients Round-Robin";
