-- =================================================================================================
-- |
-- | Fichier : automation_node_tag_resources_get_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour récupérer une relation node-tag.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_get_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_tag_resources_get',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_get(
        $node_id: string,
        $tag_id: string
    ) {
        -- Chercher la relation spécifique
        LET $relation = (
            SELECT * FROM automation_node_tag 
            WHERE node = $node_id AND tag = $tag_id
            LIMIT 1
        )[0];

        RETURN $relation;
    }
    COMMENT 'Récupère une association spécifique entre un noeud et un tag.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_tag_resources_get',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour récupérer une relation node-tag.'
PERMISSIONS FULL;
