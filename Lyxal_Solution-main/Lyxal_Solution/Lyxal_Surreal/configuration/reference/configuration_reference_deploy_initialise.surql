-- =============================================================================================
-- |
-- | Fichier : configuration_reference_deploy_initialise.surql
-- | Module : configuration
-- | Description : Orchestre le déploiement des données de référence du module Configuration.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_reference_deploy_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_deploy_initialise(
        'module', 'start', 'Configuration Reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE FUNCTION IF NOT EXISTS fn::configuration_reference_deploy(
        $parent_run_id: option<string>
    ) {
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_configuration'];
        LET $total_steps = 1; -- Ajouter d'autres jeux de données plus tard
        LET $step = 0;
        LET $run_id = rand::uuid();

        fn::system_log_deploy_helper_summary('Déploiement des données de référence `Configuration`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Références du menu (ui_menu_item)
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Déploiement des références `MenuItem`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_menu_item_reference_deploy_initialise($run_id);
        fn::configuration_menu_item_reference_deploy($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Déploiement des références `MenuItem`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des données de référence `Configuration`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les références Configuration (ui_menu_item).'
    PERMISSIONS FULL;

    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Configuration Reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement des références du module Configuration.'
PERMISSIONS FULL;


