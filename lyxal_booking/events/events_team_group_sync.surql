-- ============================================================================
-- EVENT : sync_team_group_members
-- Table  : team_group
-- Event  : CREATE / DELETE
-- Desc   : Synchronisation réactive des membres OIDC lors de la liaison/déliage d'un groupe à une équipe
-- ============================================================================

-- A. À la création de la liaison d'un groupe OIDC
DEFINE EVENT IF NOT EXISTS on_team_group_created ON TABLE team_group 
WHEN $event = "CREATE" THEN {
    LET $gid = $value.group_id;
    LET $tid = $value.team_id;
    FOR $uid IN (SELECT VALUE user_id FROM user_group WHERE group_id = $gid) {
        LET $existing = SELECT VALUE id FROM booking_team_member WHERE team = $tid AND user = $uid;
        IF array::len($existing) == 0 {
            CREATE booking_team_member CONTENT {
                team: $tid,
                user: $uid,
                role: 'member',
                source: 'group',
                created_at: time::now()
            };
        };
    };
};

-- B. À la suppression du lien d'un groupe OIDC
DEFINE EVENT IF NOT EXISTS on_team_group_deleted ON TABLE team_group 
WHEN $event = "DELETE" THEN {
    LET $gid = $before.group_id;
    LET $tid = $before.team_id;
    LET $gusers = SELECT VALUE user_id FROM user_group WHERE group_id = $gid;
    DELETE booking_team_member WHERE team = $tid AND source = 'group' AND user IN $gusers;
};
