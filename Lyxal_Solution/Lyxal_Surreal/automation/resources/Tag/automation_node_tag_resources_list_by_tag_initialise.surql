-- =================================================================================================
-- |
-- | Fichier : automation_node_tag_resources_list_by_tag_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour lister les noeuds d'un tag.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_list_by_tag_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_tag_resources_list_by_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_list_by_tag(
        $tag_id: string,
        $limit: option<number>,
        $start: option<number>
    ) {
        LET $lim = $limit ?? 50;
        LET $st = $start ?? 0;

        RETURN (
            SELECT node, node.name AS node_name FROM automation_node_tag 
            WHERE tag = $tag_id
            ORDER BY node.name ASC
            LIMIT $lim
            START $st
            FETCH node
        );
    }
    COMMENT 'Récupère une liste des noeuds associés à un tag spécifique, triée par nom de noeud.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_tag_resources_list_by_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour lister les noeuds d\'un tag.'
PERMISSIONS FULL;
