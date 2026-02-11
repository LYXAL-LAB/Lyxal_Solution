-- =============================================================================================
-- |
-- | Fichier : configuration_resources_deploy_initialise.surql
-- | Module : configuration
-- | Description : Orchestre le déploiement des ressources du module Configuration.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_resources_deploy_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_deploy_initialise(
        'module', 'start', 'Configuration Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE FUNCTION IF NOT EXISTS fn::configuration_resources_deploy(
        $parent_run_id: option<string>
    ) {
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_configuration'];
        LET $total_steps = 1; -- Ajouter d'autres sous-modules ici si besoin
        LET $step = 0;
        LET $run_id = rand::uuid();

        fn::system_log_deploy_helper_summary('Déploiement des ressources `Configuration`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des ressources `ui_menu_item`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Déploiement des ressources `MenuItem`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_menu_item_resources_deploy_initialise($run_id);
        fn::configuration_menu_item_resources_deploy($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Déploiement des ressources `MenuItem`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Configuration`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les ressources Configuration en orchestrant ui_menu_item.'
    PERMISSIONS FULL;

    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Configuration Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement des ressources du module Configuration.'
PERMISSIONS FULL;


