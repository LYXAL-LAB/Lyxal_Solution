-- ============================================================================
-- EVENT : on_team_deleted
-- Table  : booking_team
-- Event  : DELETE
-- Desc   : Nettoyage et dissociation automatique des dépendances à la suppression d'une équipe
-- ============================================================================

DEFINE EVENT IF NOT EXISTS on_team_deleted ON TABLE booking_team 
WHEN $event = "DELETE" THEN {
    -- 1. Supprime les membres associés à l'équipe
    DELETE booking_team_member WHERE team = $before.id;

    -- 2. Supprime les liaisons de groupes OIDC
    DELETE team_group WHERE team_id = $before.id;

    -- 3. Dissocie l'équipe des types d'événements sans les supprimer
    UPDATE booking_event_type SET team_id = NONE WHERE team_id = $before.id;
};
