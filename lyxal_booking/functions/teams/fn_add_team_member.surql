-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_add_team_member                                            â”‚
-- â”‚  Ajout ou mise Ã  jour d'un membre dans une Ã©quipe (Graph Relation)      â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_add_team_member(
    $team_id: option<record<booking_team>>,
    $account_id: option<record<booking_account>>,
    $role: option<string>,
    $weight: option<int>
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
    -- 2. NETTOYAGE DES VALEURS OPTIONNELLES ET POIDS
    -- ------------------------------------------------------------------------
    LET $clean_role = IF $role != NONE { string::lowercase(string::trim($role)) } ELSE { 'member' };
    IF $clean_role NOT IN ['owner', 'admin', 'member'] {
        THROW "Role must be one of: 'owner', 'admin', 'member'";
    };

    LET $clean_weight = IF $weight != NONE { $weight } ELSE { 100 };
    IF $clean_weight < 0 OR $clean_weight > 100 {
        THROW "Weight must be an integer between 0 and 100";
    };

    -- ------------------------------------------------------------------------
    -- 3. RECHERCHE ET UPSERT DANS LA RELATION GRAPH (booking_team_member)
    -- ------------------------------------------------------------------------
    LET $existing = SELECT VALUE id FROM booking_team_member WHERE in = $account_id AND out = $team_id LIMIT 1;

    RETURN IF array::len($existing) > 0 {
        UPDATE $existing[0] SET role = $clean_role, weight = $clean_weight
    } ELSE {
        CREATE booking_team_member CONTENT {
            in: $account_id,
            out: $team_id,
            role: $clean_role,
            weight: $clean_weight,
            source: 'direct',
            created_at: time::now()
        }
    };
} COMMENT "Ajoute ou met Ã  jour un membre dans une Ã©quipe via la relation Graph booking_team_member";
