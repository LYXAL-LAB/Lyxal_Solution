-- =================================================================================================
-- |
-- | Fichier : storage_database_deploy_initialise.surql
-- | Module : storage
-- | Description : Déploie les tables de la base de données pour le module de stockage.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::storage_database_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'table', 'start', 'Database',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::storage_database_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_storage'];
        LET $total_steps = 14;
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des tables `Storage`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_type`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_type`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_type_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_type`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_file`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_file`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_file_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_file`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_file_version`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_file_version`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_file_version_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_file_version`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_file_trash`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_file_trash`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_file_trash_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_file_trash`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_file_share`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_file_share`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_file_share_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_file_share`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_tag`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_tag`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_tag_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_tag`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_tag_group`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_tag_group`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_tag_group_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_tag_group`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_file_tag`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_file_tag`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_file_tag_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_file_tag`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_comment`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_comment`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_comment_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_comment`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_comment_read_marker`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_comment_read_marker`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_comment_read_marker_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_comment_read_marker`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_comment_reaction`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_comment_reaction`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_comment_reaction_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_comment_reaction`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_config`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_config`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_config_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_config`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_mount`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_mount`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_mount_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_mount`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialisation de la table `storage_file_lock`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
         'Initialisation de la table `storage_file_lock`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::storage_file_lock_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table', 
        'Initialisation de la table `storage_file_lock`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des tables `Storage`', 'finish',
         $run_id, $parent_run_id, $log_extra_tags);

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les tables de la base de données Storage.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'table', 'done', 'Database',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement agrégée des tables Storage.'
PERMISSIONS FULL;
