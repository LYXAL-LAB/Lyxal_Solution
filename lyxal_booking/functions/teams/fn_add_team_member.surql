-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_add_team_member                                            │
-- │  Ajout ou mise à jour d'un membre dans une équipe (Graph Relation)      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_add_team_member($params: object) {
    LET $team_id = IF $params.team_id != NONE { type::record(type::string($params.team_id)) } ELSE { NONE };
    LET $account_id = IF $params.account_id != NONE { type::record(type::string($params.account_id)) } 
                      ELSE IF $params.user_id != NONE { type::record(type::string($params.user_id)) } 
                      ELSE { NONE };
    LET $role = $params.role;
    LET $weight = $params.weight;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $team_id == NONE {
        RETURN fn::result_error("BOOKING_TEAM_ID_REQUIRED", $language, { field: "team_id" });
    };
    IF $account_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_ID_REQUIRED", $language, { field: "user_id" });
    };

    LET $clean_role = IF $role != NONE { string::lowercase(string::trim($role)) } ELSE { 'member' };
    LET $clean_weight = IF $weight != NONE { type::int($weight) } ELSE { 100 };

    LET $res = RELATE ONLY $account_id->booking_team_member->$team_id SET
        role = $clean_role,
        weight = $clean_weight,
        source = 'direct',
        created_at = time::now();

    RETURN fn::result_ok({
        id: $res.id,
        role: $res.role
    });
} COMMENT "Ajoute ou met à jour un membre dans une équipe via la relation Graph booking_team_member";
