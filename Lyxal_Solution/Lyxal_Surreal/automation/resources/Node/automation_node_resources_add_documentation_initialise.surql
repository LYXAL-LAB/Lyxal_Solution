-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_add_documentation_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour lier une documentation à un node.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_add_documentation_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_add_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_add_documentation(
        $node_name: string,
        $documentation_name: string
    ) {
        -- Récupération des IDs à partir des noms
        LET $node_id = (SELECT VALUE id FROM automation_node WHERE name = $node_name)[0];
        LET $documentation_id = (SELECT VALUE id FROM system_documentation WHERE name = $documentation_name)[0];

        -- Vérification de l'existence
        IF $node_id = NONE OR $documentation_id = NONE {
            THROW "Le node ou la documentation spécifiée n'existe pas.";
        };

        -- Création de la relation
        RETURN RELATE $node_id->automation_node_documentation->$documentation_id;
    }
    COMMENT 'Lie un enregistrement de documentation existant à un node en utilisant leurs noms.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_add_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT 'Initialise la fonction pour lier une documentation à un node.'
PERMISSIONS FULL;
