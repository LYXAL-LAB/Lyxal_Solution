-- =============================================================================================
-- |
-- | Fichier : automation_node_tables_deploy_initialise.surql
-- | Module : automation
-- | Description : Orchestrateur de déploiement des tables Node (automation_node, relations Node).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tables_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'table', 'start', 'Node',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tables_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 13; -- tables node (provider moved to integrations)
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des tables `Node`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node`
        -- Mise à jour de l'étape
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_documentation`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_documentation`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_documentation_create_table_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_documentation`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_webhook`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_webhook`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_webhook_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_webhook`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_credential`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_credential`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_credential_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_credential`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_param`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_param_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_param_option`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param_option`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_param_option_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param_option`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_param_mode`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param_mode`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_param_mode_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param_mode`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_param_validation`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param_validation`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_param_validation_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_param_validation`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_search_provider`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_search_provider`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_search_provider_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_search_provider`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_group`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_group`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_group_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_group`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la relation `automation_node_group_member`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la relation `automation_node_group_member`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_group_member_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la relation `automation_node_group_member`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_port`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_port`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_port_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_port`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_codex_category`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_codex_category`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_codex_category_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_codex_category`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_node_codex_subcategory`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_codex_subcategory`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_codex_subcategory_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_codex_subcategory`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la relation `automation_node_codex_member`
        LET $step = $step + 1;
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la relation `automation_node_codex_member`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::automation_node_codex_member_table_create_initialise($run_id);
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la relation `automation_node_codex_member`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des tables `Node`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les tables Node (automation_provider, automation_node et relations rattachées).'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'table', 'done', 'Node',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise l\'orchestrateur de déploiement des tables Node.'
PERMISSIONS FULL;


