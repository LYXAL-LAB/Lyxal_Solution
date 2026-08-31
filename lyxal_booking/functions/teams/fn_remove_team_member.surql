-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_remove_team_member                                         â”‚
-- â”‚  Retrait d'un membre d'une Ã©quipe (Relation Graph booking_team_member)  â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_remove_team_member(
    $team_id: option<record<booking_team>>,
    $account_id: option<record<booking_account>>
) {
    -- ------------------------------------------------------------------------
    -- 1. VÃ‰RIFICATION DES PARAMÃˆTRES OBLIGATOIRES
    -- ------------------------------------------------------------------------
    IF $team_id == NONE {
        THROW "Parameter 'team_id' is required";
    };
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };

    -- ------------------------------------------------------------------------
    -- 2. SUPPRESSION DE LA RELATION GRAPH
    -- ------------------------------------------------------------------------
    DELETE booking_team_member WHERE in = $account_id AND out = $team_id;

    RETURN true;
} COMMENT "Retire un utilisateur d'une Ã©quipe via la suppression de l'arÃªte Graph booking_team_member";
