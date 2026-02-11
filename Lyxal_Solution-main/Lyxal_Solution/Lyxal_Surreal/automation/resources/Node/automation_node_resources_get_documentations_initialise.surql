-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_get_documentations_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour récupérer les documentations d'un node.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_get_documentations_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_get_documentations',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_get_documentations(
        $node_name: string
    ) {
        -- Récupération de l'ID du node à partir du nom
        LET $node_id = (SELECT VALUE id FROM automation_node WHERE name = $node_name)[0];

        -- Si le node n'existe pas, retourner un tableau vide
        IF $node_id = NONE {
            RETURN [];
        };

        -- Récupération des documentations liées
        RETURN SELECT ->automation_node_documentation->system_documentation.* FROM $node_id;
    }
    COMMENT 'Récupère tous les enregistrements de documentation liés à un node par son nom.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_get_documentations',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT "Initialise la fonction pour récupérer les documentations d'un node."
PERMISSIONS FULL;
