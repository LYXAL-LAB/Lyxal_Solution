-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_get_list_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de récupération de la liste des nodes.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_node_resources_get_list_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_get_list',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION fn::automation_node_resources_get_list() {
        -- Récupération des nodes
        LET $nodes = (SELECT * FROM automation_node);

        -- Journalisation de fin
        fn::system_log_helper_initialise(
            'function', 'done', 'automation_node_get_list',
            { run_id: $run_id, parent_run_id: $parent_run_id, count: array::len($nodes) },
            $log_extra_tags
        );

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            data: $nodes
        };
    }
    COMMENT 'Récupère la liste de tous les nodes.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_get_list',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT "Initialise la fonction de récupération de la liste des nodes."
PERMISSIONS FULL;
