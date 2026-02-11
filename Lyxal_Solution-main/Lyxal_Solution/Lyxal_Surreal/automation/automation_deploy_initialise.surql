-- =================================================================================================
-- |
-- | Fichier : automation_deploy_initialise.surql
-- | Module : automation
-- | Description : Déploie le module Automation (Database -> Resources -> Reference).
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'module', 'start', 'Automation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION IF NOT EXISTS fn::automation_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_automation'];
        LET $total_steps = 3; -- Database, Resources, Reference
        LET $step = 0;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement du module `Automation`', 'start',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Étape  : Déploiement des tables (Database)
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des tables du module Automation.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction de déploiement Database
        fn::automation_database_deploy_initialise($run_id);
        -- Déploiement Database
        fn::automation_database_deploy($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des tables du module Automation.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape  : Déploiement des ressources (Resources)
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des ressources du module Automation.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction de déploiement Resources
        fn::automation_resources_deploy_initialise($run_id);
        -- Déploiement Resources
        fn::automation_resources_deploy($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des ressources du module Automation.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape  : Déploiement des références (Reference)
        -- Mise à jour du numéro d'étape
        LET $step = $step + 1;
        -- Journalisation de début
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des données de référence du module Automation.', 'start', $run_id, $parent_run_id, $log_extra_tags);
        -- Initialisation de la fonction de déploiement Reference
        fn::automation_reference_deploy_initialise($run_id);
        -- Déploiement Reference
        fn::automation_reference_deploy($run_id);
        -- Journalisation de fin
        fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
        'Déploiement des données de référence du module Automation.', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement du module `Automation`', 'finish',
        $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie le module Automation en orchestrant Database, Resources, Reference.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_helper_deploy_initialise(
        'function', 'done', 'Automation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement du module Automation.'
PERMISSIONS FULL;


