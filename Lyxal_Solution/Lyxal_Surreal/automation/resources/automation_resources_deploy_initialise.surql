-- =================================================================================================
-- |
-- | Fichier : automation_resources_deploy_initialise.surql
-- | Module : automation
-- | Description : Agrégateur de déploiement des ressources (Node, Tag, ...).
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_resources_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'function', 'start', 'Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_resources_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 2; -- Ajouter d'autres sous-modules ici plus tard
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des ressources `Automation`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des ressources `Node`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Déploiement des ressources `Node`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_node_resources_deploy_initialise($run_id);
        -- Déploiement des ressources
        fn::automation_node_resources_deploy($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Déploiement des ressources `Node`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Déploiement des ressources `Tag`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Déploiement des ressources `Tag`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::automation_tag_resources_deploy_initialise($run_id);
        -- Déploiement des ressources
        fn::automation_tag_resources_deploy($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Déploiement des ressources `Tag`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Automation`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les ressources Automation en orchestrant Node, Tag, ...'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'resource', 'done', 'Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement agrégée des ressources Automation.'
PERMISSIONS FULL;


