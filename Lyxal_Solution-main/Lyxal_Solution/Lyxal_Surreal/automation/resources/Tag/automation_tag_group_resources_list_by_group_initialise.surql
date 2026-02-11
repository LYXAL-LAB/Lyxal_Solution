-- =================================================================================================
-- |
-- | Fichier : automation_tag_group_resources_list_by_group_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour lister les tags d'un groupe.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_list_by_group_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_group_resources_list_by_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_list_by_group(
        $group_id: string,
        $limit: option<number>,
        $start: option<number>
    ) {
        LET $lim = $limit ?? 50;
        LET $st = $start ?? 0;

        -- On utilise FETCH pour récupérer les détails complets des tags
        RETURN (
            SELECT tag, tag.name AS tag_name FROM automation_tag_group 
            WHERE group_user = type::thing('base_user_group', $group_id)
            ORDER BY tag.name ASC
            LIMIT $lim
            START $st
            FETCH tag
        );
    }
    COMMENT 'Récupère une liste des tags associés à un groupe spécifique, triée par nom de tag.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_group_resources_list_by_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour lister les tags d\'un groupe.'
PERMISSIONS FULL;
