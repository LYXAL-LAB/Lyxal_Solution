-- ================================================================================================
-- |
-- | Fichier : storage_deploy_initialise.surql
-- | Module  : storage
-- | Objet   : Orchestration du déploiement du module Storage
-- |          (Database -> Resources).
-- |
-- ================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::storage_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'module', 'start', 'Storage',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::storage_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_storage'];
        LET $total_steps = 2; -- Database, Resources
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement du module `Storage`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des tables (Database)
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des tables du module Storage.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_database_deploy_initialise($run_id);
        fn::storage_database_deploy($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des tables du module Storage.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des resources
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des ressources du module Storage.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_resources_deploy_initialise($run_id);
        fn::storage_resources_deploy($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des ressources du module Storage.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement du module `Storage`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie le module Storage en orchestrant Database et Resources.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'module', 'done', 'Storage',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement du module Storage.'
PERMISSIONS FULL;


