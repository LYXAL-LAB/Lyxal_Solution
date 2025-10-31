-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_deploy_initialise.surql
-- | Module : automation
-- | Description : Déploie les ressources pour la gestion des nodes.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'function', 'start', 'Node',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 8;
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des ressources `Node`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_resources_create`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_resources_create`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_create_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_resources_create`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_resources_get`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_resources_get`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_get_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_resources_get`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_resources_get_list`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_resources_get_list`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_get_list_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_resources_get_list`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `add_documentation`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `add_documentation`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_add_documentation_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `add_documentation`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `get_documentations`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `get_documentations`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_get_documentations_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `get_documentations`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `remove_documentation`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `remove_documentation`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_remove_documentation_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `remove_documentation`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `add_tag`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `add_tag`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_add_tag_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `add_tag`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `remove_tag`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `remove_tag`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_remove_tag_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `remove_tag`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Node`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les ressources `Node` en initialisant toutes ses fonctions.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'resource', 'done', 'Node',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT "Initialise la fonction de déploiement pour les ressources `Node`."
PERMISSIONS FULL;
