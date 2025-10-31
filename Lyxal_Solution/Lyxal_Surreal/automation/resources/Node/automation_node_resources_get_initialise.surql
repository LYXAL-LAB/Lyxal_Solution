-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_get_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de récupération d'un node.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_node_resources_get_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_get',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION fn::automation_node_resources_get(
        $node_name: string
    ) {
        -- Récupération du node
        LET $node = (SELECT * FROM automation_node WHERE name = $node_name);

        -- Journalisation de fin
        fn::system_log_helper_initialise(
            'function', 'done', 'automation_node_get',
            { run_id: $run_id, parent_run_id: $parent_run_id, data: $node[0] },
            $log_extra_tags
        );

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            data: $node[0]
        };
    }
    COMMENT 'Récupère un node par son nom.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_get',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT "Initialise la fonction de récupération d'un node."
PERMISSIONS FULL;
