-- ================================================================================================
-- |
-- | Fichier : storage_resources_deploy_initialise.surql
-- | Module  : storage
-- | Objet   : Orchestration du déploiement des ressources du module Storage
-- |          (définitions de fonctions/resources).
-- |
-- ================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::storage_resources_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'function', 'start', 'Storage Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale (resources)
    DEFINE FUNCTION IF NOT EXISTS fn::storage_resources_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_storage'];
        LET $total_steps = 1; -- Étendre si de nouvelles resources sont ajoutées
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des ressources `Storage`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape : Initialiser la fonction get_by_name (file)
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Initialisation de la ressource `storage_file_resources_get_by_name`.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction
        fn::storage_file_resources_get_by_name_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_function',
        'Initialisation de la ressource `storage_file_resources_get_by_name`.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Storage`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les resources Storage (fonctions utilitaires)'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Storage Resources',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement des resources du module Storage.'
PERMISSIONS FULL;


