-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_delete_team                                                â”‚
-- â”‚  Suppression atomique d'une Ã©quipe et nettoyage de ses dÃ©pendances       â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_delete_team(
    $team_id: option<record<booking_team>>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DU PARAMÃˆTRE OBLIGATOIRE
    -- ------------------------------------------------------------------------
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. NETTOYAGE DES DÃ‰PENDANCES ET SUPPRESSION DE L'Ã‰QUIPE (booking_team)
    -- ------------------------------------------------------------------------
    DELETE booking_team_member WHERE out = $team_id;
    DELETE booking_team_invite WHERE team = $team_id;
    UPDATE booking_event_type SET team = NONE WHERE team = $team_id;
    DELETE $team_id;

    RETURN true;
} COMMENT "Supprime une Ã©quipe ainsi que ses associations de membres, invitations et rattachements d'Ã©vÃ©nements";
