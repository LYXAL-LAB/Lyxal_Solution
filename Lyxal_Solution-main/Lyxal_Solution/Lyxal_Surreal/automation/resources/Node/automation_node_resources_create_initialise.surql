-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de création d'un nouveau node.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_create',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_create(
        $name: string,
        $icon: option<string>,
        $website_url: option<string>
    ) {
        -- Validation des paramètres
        IF $name = NONE OR string::len(string::trim($name)) = 0 {
            THROW "Le nom du node est requis.";
        };

        -- Récupération de l'enregistrement de l'icône à partir de son nom
        LET $icon_record = IF $icon != NONE {
            RETURN fn::storage_file_resources_get_by_name($icon);
        } ELSE {
            RETURN NONE;
        };

        -- Création du node (l'unicité est garantie par l'index de la table)
        LET $node = CREATE automation_node SET
            name = $name,
            icon = $icon_record,
            website_url = $website_url,
            created_at = time::now(),
            updated_at = time::now();
        
        -- Journalisation de fin
        fn::system_log_helper_initialise(
            'function', 'done', 'automation_node_create',
            { run_id: $run_id, parent_run_id: $parent_run_id, data: $node[0] },
            $log_extra_tags
        );
        
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            data: $node[0]
        };
    }
    COMMENT 'Crée un nouveau node pour les services d\'automatisation.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_create',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT 'Initialise la fonction de création de node.'
PERMISSIONS FULL;
