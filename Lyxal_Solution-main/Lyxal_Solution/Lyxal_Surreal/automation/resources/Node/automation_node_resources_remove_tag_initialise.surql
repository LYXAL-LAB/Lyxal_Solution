-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_remove_tag_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour supprimer le lien entre un tag et un node.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::automation_node_resources_remove_tag_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation', 'resource_node'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_remove_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION fn::automation_node_resources_remove_tag(
        $node_name: string,
        $tag_id: string
    ) {
        -- Récupération de l'ID du node
        LET $node_id = (SELECT VALUE id FROM automation_node WHERE name = $node_name)[0];

        -- Si le node n'existe pas, il n'y a rien à faire
        IF $node_id = NONE {
            RETURN { success: false, message: "Le node spécifié n'existe pas." };
        };

        -- Suppression de la relation
        DELETE automation_node_tag WHERE in = $node_id AND out = $tag_id;
        RETURN { success: true };
    }
    COMMENT 'Supprime le lien entre un tag et un node en utilisant le nom du node et l\'ID du tag.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_remove_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT 'Initialise la fonction pour supprimer le lien entre un tag et un node.'
PERMISSIONS FULL;
