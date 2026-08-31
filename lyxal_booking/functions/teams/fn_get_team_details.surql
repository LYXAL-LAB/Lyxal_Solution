-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_get_team_details                                          â”‚
-- â”‚  RÃ©cupÃ¨re les dÃ©tails complets d'une Ã©quipe                             â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_get_team_details(
    $team_id: option<record<booking_team>>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DU PARAMÃˆTRE OBLIGATOIRE
    -- ------------------------------------------------------------------------
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. RECHERCHE DANS LA TABLE BOOKING_TEAM
    -- ------------------------------------------------------------------------
    LET $res = SELECT *, 
                      (SELECT VALUE count() FROM booking_team_member WHERE out = $team_id) AS member_count 
                 FROM $team_id;

    RETURN IF array::len($res) > 0 { $res[0] } ELSE { NONE };
} COMMENT "RÃ©cupÃ¨re les dÃ©tails complets d'une Ã©quipe (nom, slug, description, logo, invite_token) ainsi que le nombre de membres";
