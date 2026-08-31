-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_find_manageable_event_type_by_slug                        │
-- │  Recherche un type d'événement par slug gérable par l'utilisateur      │
-- │  (priorité à l'événement individuel, puis d'équipe).                  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_find_manageable_event_type_by_slug($params: object) {
    LET $account_id = IF $params.account_id != NONE { type::record(type::string($params.account_id)) } ELSE { NONE };
    LET $slug = $params.slug;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $account_id == NONE {
        RETURN fn::result_error("BOOKING_ACCOUNT_ID_REQUIRED", $language, { field: "account_id" });
    };
    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        RETURN fn::result_error("BOOKING_SLUG_REQUIRED", $language, { field: "slug" });
    };

    LET $clean_slug = string::lowercase(string::trim($slug));

    -- 1. Essai sur l'événement individuel du compte
    LET $personal = SELECT id, slug, title, duration_min, location_type, location_value, enabled, account, team FROM booking_event_type
                     WHERE slug = $clean_slug
                       AND account = $account_id
                     LIMIT 1;
    IF array::len($personal) > 0 {
        RETURN fn::result_ok($personal[0]);
    };

    -- 2. Essai sur les événements d'équipes gérées (admin ou owner via booking_team_member)
    LET $admin_teams = SELECT VALUE out FROM booking_team_member 
                        WHERE in = $account_id 
                          AND role IN ['admin', 'owner'];

    IF array::len($admin_teams) > 0 {
        LET $team_events = SELECT id, slug, title, duration_min, location_type, location_value, enabled, account, team FROM booking_event_type
                            WHERE slug = $clean_slug
                              AND team IN $admin_teams
                            LIMIT 1;
        IF array::len($team_events) > 0 {
            RETURN fn::result_ok($team_events[0]);
        };
    };

    RETURN fn::result_ok(NULL);
} COMMENT "Recherche un type d'événement par slug modifiable par l'utilisateur (priorité individuel puis équipe)";
