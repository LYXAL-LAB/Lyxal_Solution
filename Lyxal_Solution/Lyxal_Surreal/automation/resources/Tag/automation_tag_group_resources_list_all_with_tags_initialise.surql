-- =================================================================================================
-- |
-- | Fichier : automation_tag_group_resources_list_all_with_tags_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour lister tous les groupes et leurs tags.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_list_all_with_tags_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_group_resources_list_all_with_tags',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_list_all_with_tags(
        $limit: option<number>,
        $start: option<number>
    ) {
        LET $lim = $limit ?? 50;
        LET $st = $start ?? 0;

        RETURN (
            SELECT 
                *, 
                (
                    SELECT tag, tag.name AS tag_name FROM automation_tag_group 
                    WHERE group_user = $parent.id 
                    ORDER BY tag.name ASC 
                    FETCH tag
                ) AS tags 
            FROM base_user_group
            ORDER BY name ASC
            LIMIT $lim
            START $st
        );
    }
    COMMENT 'Récupère une liste paginée de tous les groupes d\'utilisateurs avec leurs tags associés, 
    triée par nom.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_group_resources_list_all_with_tags',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour lister tous les groupes et leurs tags.'
PERMISSIONS FULL;
