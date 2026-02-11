-- =================================================================================================
-- |
-- | Fichier : automation_node_tag_resources_list_nodes_by_tags_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour lister les noeuds par une liste de tags.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_list_nodes_by_tags_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_tag_resources_list_nodes_by_tags',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_list_nodes_by_tags(
        $tag_ids: array<string>,
        $limit: option<number>,
        $start: option<number>
    ) {
        LET $lim = $limit ?? 50;
        LET $st = $start ?? 0;

        -- Récupère les noeuds uniques qui ont au moins un des tags de la liste
        RETURN (
            SELECT node, node.name AS node_name FROM automation_node_tag
            WHERE tag IN $tag_ids
            GROUP BY node
            ORDER BY node.name ASC
            LIMIT $lim
            START $st
            FETCH node
        );
    }
    COMMENT 'Récupère une liste de noeuds associés à une liste de tags, triée par nom de noeud.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_tag_resources_list_nodes_by_tags',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour lister les noeuds par une liste de tags.'
PERMISSIONS FULL;
