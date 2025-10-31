-- =================================================================================================
-- |
-- | Fichier : service_deploy_initialise.surql
-- | Module : automation
-- | Description : Déploie les ressources pour la gestion des services.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_resources_service_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'resource', 'start', 'Service',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION fn::automation_resources_service_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 3;
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des ressources `Service`', 'start', 
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_service_create`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation: début de l'étape
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_service_create`', 
        'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction de création de la fonction `automation_service_create`
        fn::automation_service_create_initialise($run_id);
        -- Journalisation: fin de l'étape
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_service_create`', 'done', 
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_service_get`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation: début de l'étape
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_service_get`', 'start', 
        $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction de création de la fonction `automation_service_get`
        fn::automation_service_get_initialise($run_id);
        -- Journalisation: fin de l'étape
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_service_get`', 'done', 
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Création de la fonction `automation_service_get_list`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation: début de l'étape
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_service_get_list`', 'start', 
        $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction de création de la fonction `automation_service_get_list`
        fn::automation_service_get_list_initialise($run_id);
        -- Journalisation: fin de l'étape
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function', 
        'Création de la fonction `automation_service_get_list`', 'done', 
        $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Service`', 'finish', 
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            message: 'Déploiement des ressources `Service` réussi avec succès.',
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les ressources `Service` en initialisant toutes ses fonctions.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'resource', 'done', 'Service',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        message: 'Initialisation de la fonction de déploiement pour les ressources `Service` 
        réussi avec succès.',
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT "Initialise la fonction de déploiement pour les ressources `Service`."
PERMISSIONS FULL;
