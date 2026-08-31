-- â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
-- â”‚  fn::booking_find_manageable_event_type_by_slug                        â”‚
-- â”‚  Recherche un type d'Ã©vÃ©nement par slug gÃ©rable par l'utilisateur      â”‚
-- â”‚  (prioritÃ© Ã  l'Ã©vÃ©nement individuel, puis d'Ã©quipe).                  â”‚
-- â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

DEFINE FUNCTION OVERWRITE fn::booking_find_manageable_event_type_by_slug(
    $account_id: option<record<booking_account>>,
    $slug: option<string>
) {
    IF $account_id == NONE {
        THROW "Parameter 'account_id' is required";
    };
    IF $slug == NONE OR string::len(string::trim($slug)) == 0 {
        THROW "Parameter 'slug' is required";
    };

    LET $clean_slug = string::lowercase(string::trim($slug));

    -- 1. Essai sur l'Ã©vÃ©nement individuel du compte
    LET $personal = SELECT * FROM booking_event_type
                     WHERE slug = $clean_slug
                       AND account = $account_id
                     LIMIT 1;
    IF array::len($personal) > 0 {
        RETURN $personal[0];
    };

    -- 2. Essai sur les Ã©vÃ©nements d'Ã©quipes gÃ©rÃ©es (admin ou owner via booking_team_member)
    LET $admin_teams = SELECT VALUE out FROM booking_team_member 
                        WHERE in = $account_id 
                          AND role IN ['admin', 'owner'];

    IF array::len($admin_teams) > 0 {
        LET $team_events = SELECT * FROM booking_event_type
                            WHERE slug = $clean_slug
                              AND team IN $admin_teams
                            LIMIT 1;
        IF array::len($team_events) > 0 {
            RETURN $team_events[0];
        };
    };

    RETURN NONE;
} COMMENT "Recherche un type d'Ã©vÃ©nement par slug modifiable par l'utilisateur (prioritÃ© individuel puis Ã©quipe)";
