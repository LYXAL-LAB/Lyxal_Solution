-- =================================================================================================
-- |
-- | Fichier : automation_reference_deploy_initialise.surql
-- | Module : automation
-- | Description : Déploie les ressources de référence pour l'automatisation.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_reference_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'data_reference', 'start', 'Reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_reference_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 1; -- Ajouter d'autres dossiers ici plus tard
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des ressources `Reference`', 'start',
         $run_id, $parent_run_id, $log_extra_tags);

        -- Étape  : Déploiement des références du dossier `Node`
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Déploiement des références du dossier `Node`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction de déploiement des références du dossier `Node`
        fn::automation_node_reference_deploy_initialise($run_id);
        -- Déploiement des références du dossier `Node`
        fn::automation_node_reference_deploy($run_id); 
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Déploiement des références du dossier `Node`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Reference`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les ressources `Reference` en initialisant toutes ses fonctions.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT "Initialise la fonction de déploiement pour les ressources de référence."
PERMISSIONS FULL;
