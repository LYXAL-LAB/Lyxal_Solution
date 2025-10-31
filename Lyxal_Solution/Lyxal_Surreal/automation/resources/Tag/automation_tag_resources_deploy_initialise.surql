-- =================================================================================================
-- |
-- | Fichier : automation_tag_resources_deploy_initialise.surql
-- | Module : automation
-- | Description : Déploie les ressources pour la gestion des tags.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'function', 'start', 'Tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 17;
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des ressources `Tag`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_resources_create`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_create`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_resources_create_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_create`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_resources_get_by_id`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_get_by_id`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_resources_get_by_id_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_get_by_id`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_resources_get_by_name`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_get_by_name`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_resources_get_by_name_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_get_by_name`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_resources_list`
        -- Mise à jour du numéro d'étape`
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_list`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_resources_list_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_list`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_resources_update`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_update`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_resources_update_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_update`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_resources_delete`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_delete`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_resources_delete_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_resources_delete`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_group_resources_add`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_add`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_group_resources_add_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_add`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_group_resources_delete`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_delete`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_group_resources_delete_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_delete`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_group_resources_get`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_get`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_group_resources_get_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_get`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_group_resources_list_by_group`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_list_by_group`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_group_resources_list_by_group_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_list_by_group`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_tag_group_resources_list_all_with_tags`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_list_all_with_tags`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_group_resources_list_all_with_tags_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_tag_group_resources_list_all_with_tags`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_tag_resources_add`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_add`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_tag_resources_add_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_add`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_tag_resources_delete`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_delete`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);   
        -- Initialisation de la fonction
        fn::automation_node_tag_resources_delete_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_delete`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_tag_resources_get`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_get`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_tag_resources_get_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_get`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_tag_resources_list_by_node`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_list_by_node`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_tag_resources_list_by_node_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_list_by_node`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_tag_resources_list_by_tag`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_list_by_tag`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_tag_resources_list_by_tag_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_list_by_tag`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_node_tag_resources_list_nodes_by_tags`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_list_nodes_by_tags`', 'start', $run_id, 
        $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_tag_resources_list_nodes_by_tags_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_node_tag_resources_list_nodes_by_tags`', 'done', $run_id, 
        $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Tag`', 'finish', 
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les ressources `Tag` en initialisant toutes ses fonctions.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'resource', 'done', 'Tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement pour les ressources `Tag`.'
PERMISSIONS FULL;


