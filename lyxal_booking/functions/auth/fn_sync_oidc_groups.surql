-- ============================================================================
-- SYNCHRONISATION ATOMIQUE DIFFERENTIELLE DES GROUPES ET EQUIPES OIDC (MODÈLE GRAPH PUR IN/OUT)
-- MODULE : lyxal_booking
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_sync_oidc_groups(
    $params: object
) {
    LET $account_id = $params.account_id;
    LET $provider = $params.provider OR "oidc";
    LET $groups = $params.groups OR [];
    LET $language = $params.language OR "fr";

    IF $account_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_NOT_FOUND", $language, { field: "account_id" });
    };

    LET $groups_received = array::len($groups);
    LET $groups_created = 0;
    LET $memberships_added = 0;

    -- Invalidation des anciennes associations OIDC du compte (modèle Graph pure: in -> out)
    LET $old_memberships = SELECT id FROM booking_group_member WHERE in = $account_id AND source = $provider;
    LET $memberships_removed = array::len($old_memberships);
    DELETE booking_group_member WHERE in = $account_id AND source = $provider;

    LET $group_ids = [];

    -- 1. Création/Recherche des groupes par provider + external_group_id et rattachement
    FOR $group_item IN $groups {
        LET $raw_name = IF type::is::string($group_item) { $group_item } ELSE { $group_item.name };
        LET $clean_name = string::lowercase(string::trim($raw_name));
        LET $ext_id = IF type::is::object($group_item) AND $group_item.id != NONE { $group_item.id } ELSE { $clean_name };

        IF string::len($clean_name) > 0 {
            LET $grp_id = type::thing("booking_group", [$provider, $ext_id]);
            LET $existing_grp = SELECT id FROM $grp_id LIMIT 1;
            IF array::len($existing_grp) == 0 {
                LET $groups_created = $groups_created + 1;
            };

            LET $grp = UPSERT ONLY $grp_id CONTENT {
                provider: $provider,
                external_id: $ext_id,
                display_name: $clean_name,
                source: $provider,
                updated_at: time::now()
            };

            RELATE ($account_id)->booking_group_member->($grp.id) CONTENT {
                source: $provider,
                created_at: time::now()
            };
            LET $memberships_added = $memberships_added + 1;
            LET $group_ids = array::add($group_ids, $grp.id);
        };
    };

    -- 2. Synchronisation des équipes associées aux groupes OIDC (AUDIT-004)
    LET $team_memberships_added = 0;
    LET $team_memberships_removed = 0;

    -- Recherche des équipes liées aux groupes OIDC actuels via booking_team_group (modèle Graph: in = group, out = team)
    LET $linked_teams = SELECT VALUE out FROM booking_team_group WHERE in IN $group_ids;

    -- Invalidation des adhésions d'équipe obsolètes ayant source = 'group' (PRESERVE source = 'direct')
    LET $stale_team_memberships = SELECT id FROM booking_team_member WHERE in = $account_id AND source = 'group' AND out NOT IN $linked_teams;
    LET $team_memberships_removed = array::len($stale_team_memberships);
    DELETE booking_team_member WHERE in = $account_id AND source = 'group' AND out NOT IN $linked_teams;

    -- Rattachement aux équipes liées
    FOR $team_id IN $linked_teams {
        LET $existing_member = SELECT id FROM booking_team_member WHERE in = $account_id AND out = $team_id LIMIT 1;
        IF array::len($existing_member) == 0 {
            RELATE $account_id->booking_team_member->$team_id CONTENT {
                role: "member",
                source: "group",
                created_at: time::now()
            };
            LET $team_memberships_added = $team_memberships_added + 1;
        };
    };

    RETURN fn::result_ok({
        groups_received: $groups_received,
        groups_created: $groups_created,
        memberships_added: $memberships_added,
        memberships_removed: $memberships_removed,
        team_memberships_added: $team_memberships_added,
        team_memberships_removed: $team_memberships_removed
    });
};
