-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_remove_documentation_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour supprimer le lien entre une documentation et un node.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_node_resources_remove_documentation_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation', 'resource_node'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_remove_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION fn::automation_node_resources_remove_documentation(
        $node_name: string,
        $documentation_name: string
    ) {
        -- Récupération des IDs à partir des noms
        LET $node_id = (SELECT VALUE id FROM automation_node WHERE name = $node_name)[0];
        LET $documentation_id = (SELECT VALUE id FROM system_documentation 
        WHERE name = $documentation_name)[0];

        -- Si l'un ou l'autre n'existe pas, il n'y a rien à faire
        IF $node_id = NONE OR $documentation_id = NONE {
            RETURN { success: false, message: "Le node ou la documentation spécifiée n'existe pas." };
        };

        -- Suppression de la relation
        DELETE automation_node_documentation WHERE in = $node_id AND out = $documentation_id;
        RETURN { success: true };
    }
    COMMENT 'Supprime le lien entre une documentation et un node en utilisant leurs noms.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_remove_documentation',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT "Initialise la fonction pour supprimer le lien entre une documentation et un node."
PERMISSIONS FULL;
