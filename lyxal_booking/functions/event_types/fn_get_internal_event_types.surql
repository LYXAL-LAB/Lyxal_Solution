-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_internal_event_types                                  │
-- │  Récupère la liste des types d'événements internes à l'organisation    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_internal_event_types() {
    RETURN SELECT 
        id, 
        slug, 
        title, 
        duration_min, 
        account.name AS host_name, 
        account.username AS username, 
        team.name AS team_name, 
        team.slug AS team_slug,
        created_at
    FROM booking_event_type
    WHERE enabled = true
    ORDER BY created_at ASC;
};
