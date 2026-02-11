-- =================================================================================================
-- |
-- | Fichier : automation_node_resources_add_tag_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour lier un tag à un node.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_add_tag_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_resources_add_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_resources_add_tag(
        $node_name: string,
        $tag_id: string
    ) {
        -- Récupération de l'ID du node
        LET $node_id = (SELECT VALUE id FROM automation_node WHERE name = $node_name)[0];

        -- Vérification de l'existence du node
        IF $node_id = NONE {
            THROW "Le node spécifié n'existe pas.";
        };

        -- Création de la relation
        RETURN RELATE $node_id->automation_node_tag->$tag_id;
    }
    COMMENT 'Lie un tag existant à un node en utilisant leurs noms et ID.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_resources_add_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT 'Initialise la fonction pour lier un tag à un node.'
PERMISSIONS FULL;
