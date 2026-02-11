-- Initialisation de la fonction de déploiement de la section builder_documentation
DEFINE FUNCTION fn::builder_documentation_deploy_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue'];
    LET $run_id = rand::uuid();

    -- Journalisation du début du déploiement
    fn::system_log_create_record_system(
        ['log_initialisation', 'log_section', 'log_deploy', 'log_start'],
        'Start: initialisation de la fonction de déploiement pour la section `builder_documentation`',
        { run_id: $run_id, parent_run_id: $parent_run_id }
    );

    -- Définition de la fonction de déploiement principale
    DEFINE FUNCTION fn::builder_documentation_deploy(
        $parent_run_id: option<string>
    ) {
        -- Paramètres
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_builder', 'sub_module_builder_catalogue', 'log_deploy'];
        LET $total_steps = 6;
        LET $run_id = rand::uuid();

        -- Journalisation du résumé du déploiement
        fn::system_log_deploy_helper_summary('Déploiement de la section `builder_documentation`', 'start', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape 1: Création de la table builder_documentation
        fn::system_log_deploy_helper_step(1, $total_steps, 'log_table', 'Création de la table `builder_documentation`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::builder_documentation_create_table_initialise($run_id);
        fn::system_log_deploy_helper_step(1, $total_steps, 'log_table', 'Création de la table `builder_documentation`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape 2: Création de la fonction builder_documentation_add_record
        fn::system_log_deploy_helper_step(2, $total_steps, 'log_function', 'Création de la fonction `builder_documentation_add_record`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::builder_documentation_add_record_initialise($run_id);
        fn::system_log_deploy_helper_step(2, $total_steps, 'log_function', 'Création de la fonction `builder_documentation_add_record`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape 3: Création de la fonction helper builder_documentation_build_where_clause
        fn::system_log_deploy_helper_step(3, $total_steps, 'log_function', 'Création de la fonction helper `builder_documentation_build_where_clause`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::builder_documentation_build_where_clause_initialise($run_id);
        fn::system_log_deploy_helper_step(3, $total_steps, 'log_function', 'Création de la fonction helper `builder_documentation_build_where_clause`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape 4: Création de la fonction de recherche builder_documentation_get_records
        fn::system_log_deploy_helper_step(4, $total_steps, 'log_function', 'Création de la fonction `builder_documentation_get_records`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::builder_documentation_get_records_initialise($run_id);
        fn::system_log_deploy_helper_step(4, $total_steps, 'log_function', 'Création de la fonction `builder_documentation_get_records`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape 5: Création de la fonction de suppression builder_documentation_remove_record
        fn::system_log_deploy_helper_step(5, $total_steps, 'log_function', 'Création de la fonction `builder_documentation_remove_record`', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::builder_documentation_remove_record_initialise($run_id);
        fn::system_log_deploy_helper_step(5, $total_steps, 'log_function', 'Création de la fonction `builder_documentation_remove_record`', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Étape 6: Création des tags de référence
        fn::system_log_deploy_helper_step(6, $total_steps, 'log_reference_tags', 'Création des tags de référence', 'start', $run_id, $parent_run_id, $log_extra_tags);
        fn::builder_documentation_reference_tags_initialise($run_id);
        fn::builder_documentation_reference_tags($run_id);
        fn::system_log_deploy_helper_step(6, $total_steps, 'log_reference_tags', 'Création des tags de référence', 'done', $run_id, $parent_run_id, $log_extra_tags);

        -- Journalisation de la fin du déploiement
        LET $summary = fn::system_log_deploy_helper_summary('Déploiement de la section `builder_documentation`', 'finish', $run_id, $parent_run_id, $log_extra_tags);

        -- Retour de la fonction
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            summary: $summary
        };
    }
    COMMENT 'Déploie la section builder_documentation.'
    PERMISSIONS FULL;

    -- Journalisation de la fin de l'initialisation
    fn::system_log_create_record_system(
        ['log_initialisation', 'log_section', 'log_deploy', 'log_done', 'log_success'],
        'Done: initialisation de la fonction de déploiement pour la section `builder_documentation`',
        { run_id: $run_id, parent_run_id: $parent_run_id }
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement pour la section builder_documentation.'
PERMISSIONS FULL;
