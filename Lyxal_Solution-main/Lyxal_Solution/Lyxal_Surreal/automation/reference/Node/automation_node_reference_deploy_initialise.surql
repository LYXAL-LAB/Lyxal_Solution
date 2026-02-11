-- =================================================================================================
-- |
-- | Fichier : automation_node_reference_deploy_initialise.surql
-- | Module : automation
-- | Description : Déploie les données de référence des nodes : 1) nodes, 2) tags, 3) relations.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_reference_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'data_reference', 'start', 'Node Reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_reference_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 3; -- Nombre total d'étapes
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement des ressources `Node Reference`', 'start',
         $run_id, $parent_run_id, $log_extra_tags);

        -- Étape  : Initialisation des nodes de référence
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Initialisation des nodes de référence.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation des nodes de référence
        fn::automation_node_reference_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Initialisation des nodes de référence.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape  : Initialisation des tags de référence
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Initialisation des tags de référence.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation des tags de référence
        fn::automation_node_reference_tags_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Initialisation des tags de référence.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape  : Initialisation des relations entre nodes et tags
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Initialisation des relations de tags pour les nodes.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation des relations entre nodes et tags
        fn::automation_node_reference_relation_tags_initialise($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_reference',
        'Initialisation des relations de tags pour les nodes.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Node Reference`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie les ressources `Node Reference` en initialisant les nodes, tags et relations.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'data_reference', 'done', 'Node Reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement pour les ressources de référence `Node`.'
PERMISSIONS FULL;


