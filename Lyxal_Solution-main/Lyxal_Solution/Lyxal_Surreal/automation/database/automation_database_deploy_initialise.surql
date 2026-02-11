-- =================================================================================================
-- |
-- | Fichier : automation_database_deploy_initialise.surql
-- | Module : automation
-- | Description : Agrégateur de déploiement des tables de la base (Tag, ...).
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_database_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'table', 'start', 'Database',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_database_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 2; -- Node + Tag
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des tables `Automation`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des tables `Node`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Déploiement des tables `Node`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_tables_deploy_initialise($run_id);
        -- Déploiement des tables
        fn::automation_node_tables_deploy($run_id);
        -- Journalisation de fin de l'étape
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Déploiement des tables `Node`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des tables `Tag`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Déploiement des tables `Tag`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_tables_deploy_initialise($run_id);
        -- Déploiement des tables
        fn::automation_tag_tables_deploy($run_id);
        -- Journalisation de fin de step
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Déploiement des tables `Tag`', 'done', $run_id, $parent_run_id, $log_extra_tags);
        
        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des tables `Automation`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les tables Automation en orchestrant Tag, ...'
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
COMMENT 'Initialise la fonction de déploiement agrégée des tables Automation.'
PERMISSIONS FULL;


