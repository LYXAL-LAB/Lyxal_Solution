-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_resources_deploy_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Orchestrateur des ressources MenuItem (logs start/done).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_resources_deploy_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_deploy_initialise(
        'function', 'start', 'Configuration MenuItem Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_resources_deploy(
        $parent_run_id: option<string>
    ) {
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_configuration'];
        LET $run_id = rand::uuid();

        fn::system_log_deploy_helper_summary('Déploiement des ressources `Configuration/MenuItem`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Les fonctions CRUD/list sont définies via leurs fichiers dédiés lors de l'import.
        -- Ici, on ne fait qu'encadrer par des logs d'orchestration.

        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Configuration/MenuItem`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id, summary: $summary };
    }
    COMMENT 'Déploie les ressources MenuItem (orchestration/trace).'
    PERMISSIONS FULL;

    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Configuration MenuItem Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise l\'orchestrateur des ressources MenuItem.'
PERMISSIONS FULL;


