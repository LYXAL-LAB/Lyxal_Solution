-- =============================================================================================
-- |
-- | Fichier : configuration_database_deploy_initialise.surql
-- | Module : configuration
-- | Description : Orchestre le déploiement des tables du module Configuration.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_database_deploy_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_deploy_initialise(
        'module', 'start', 'Configuration Database',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE FUNCTION IF NOT EXISTS fn::configuration_database_deploy(
        $parent_run_id: option<string>
    ) {
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_configuration'];
        LET $total_steps = 5; -- MenuItem, UIEventType, UIEvent, UIRoute, UIItemEvent
        LET $step = 0;
        LET $run_id = rand::uuid();

        fn::system_log_deploy_helper_summary('Déploiement des tables `Configuration`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Table ui_menu_item
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `ui_menu_item`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_menu_item_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `ui_menu_item`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Table configuration_ui_event_type
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_event_type`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_ui_event_type_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_event_type`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Table configuration_ui_event
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_event`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_ui_event_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_event`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Table configuration_ui_route
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_route`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_ui_route_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_route`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Table configuration_ui_item_event
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_item_event`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_ui_item_event_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création/validation de la table `configuration_ui_item_event`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des tables `Configuration`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les tables du module Configuration.'
    PERMISSIONS FULL;

    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Configuration Database',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise l\'orchestrateur de déploiement des tables du module Configuration.'
PERMISSIONS FULL;


