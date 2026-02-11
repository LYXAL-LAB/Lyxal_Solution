-- =============================================================================================
-- |
-- | Fichier : configuration_deploy_initialise.surql
-- | Module : configuration
-- | Description : Déploie le module Configuration (Database -> Resources -> Reference).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_deploy_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_deploy_initialise(
        'module', 'start', 'Configuration',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE FUNCTION IF NOT EXISTS fn::configuration_deploy(
        $parent_run_id: option<string>
    ) {
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_configuration'];
        LET $total_steps = 3; -- Database, Resources, Reference
        LET $step = 0;
        LET $run_id = rand::uuid();

        fn::system_log_deploy_helper_summary('Déploiement du module `Configuration`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des tables (Database)
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des tables du module Configuration.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_database_deploy_initialise($run_id);
        fn::configuration_database_deploy($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des tables du module Configuration.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des ressources (Resources)
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des ressources du module Configuration.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_resources_deploy_initialise($run_id);
        fn::configuration_resources_deploy($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des ressources du module Configuration.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des références (Reference)
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des données de référence du module Configuration.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::configuration_reference_deploy_initialise($run_id);
        fn::configuration_reference_deploy($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des données de référence du module Configuration.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        LET $summary = fn::system_log_deploy_helper_summary('Déploiement du module `Configuration`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie le module Configuration en orchestrant Database, Resources, Reference.'
    PERMISSIONS FULL;

    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Configuration',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement du module Configuration.'
PERMISSIONS FULL;


