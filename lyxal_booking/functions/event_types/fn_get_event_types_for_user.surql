-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_event_types_for_user                                  │
-- │  Récupère la liste des types d'événements d'équipe accessibles          │
-- │  à l'utilisateur (ou tous si administrateur).                          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_event_types_for_user(
    $account_id: option<record<booking_account>>,
    $is_admin: option<bool>
) {
    LET $admin_flag = IF $is_admin != NONE { $is_admin } ELSE { false };

    IF $admin_flag == false AND $account_id == NONE {
        THROW "Parameter 'account_id' is required for non-admin users";
    };

    RETURN IF $admin_flag {
        -- Administrateur : retourne tous les types d'événements d'équipe
        SELECT *, 
               team.name AS team_name, 
               team.slug AS team_slug, 
               (SELECT VALUE count() FROM booking WHERE event_type = $parent.id AND status IN ['confirmed', 'pending']) AS active_bookings 
          FROM booking_event_type 
         WHERE team != NONE 
         ORDER BY team.name, created_at
    } ELSE {
        -- Utilisateur standard : retourne les types d'événements des équipes dont il est membre
        LET $user_teams = SELECT VALUE out FROM booking_team_member WHERE in = $account_id;
        SELECT *, 
               team.name AS team_name, 
               team.slug AS team_slug, 
               (SELECT VALUE count() FROM booking WHERE event_type = $parent.id AND status IN ['confirmed', 'pending']) AS active_bookings 
          FROM booking_event_type 
         WHERE team != NONE 
           AND team IN $user_teams 
         ORDER BY team.name, created_at
    };
};
