-- =================================================================================================
-- |
-- | Fichier : automation_tag_tables_deploy_initialise.surql
-- | Module : automation
-- | Description : Déploie les tables de tags (automation_tag, automation_tag_group, 
-- | automation_node_tag).
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_tables_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'table', 'start', 'Tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_tables_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 3; -- Tables: tag, tag_group, node_tag
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des tables `Tag`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_tag`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_tag`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_table_create_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_tag`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la table `automation_tag_group`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_tag_group`', 'start', $run_id, $parent_run_id, 
        $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_group_table_create_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_tag_group`', 'done', $run_id, $parent_run_id, 
        $log_extra_tags);

        -- Étape : Création de la table `automation_node_tag`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_tag`', 'start', $run_id, $parent_run_id, 
        $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_tag_table_create_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_table',
        'Création de la table `automation_node_tag`', 'done', $run_id, $parent_run_id, 
        $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des tables `Tag`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les tables de tags: automation_tag, automation_tag_group, automation_node_tag.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'table', 'done', 'Tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement des tables de tags.'
PERMISSIONS FULL;


