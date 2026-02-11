-- =================================================================================================
-- |
-- | Fichier : automation_node_tag_resources_add_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour ajouter un tag à un noeud.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_add_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_node_tag_resources_add',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_node_tag_resources_add(
        $node_name: string,
        $tag_name: string
    ) {
        -- Résoudre les identifiants à partir des noms
        LET $node_rec = SELECT id FROM automation_node WHERE name = $node_name LIMIT 1;
        IF array::len($node_rec) = 0 {
            RETURN { success: false, error: 'Node not found', node_name: $node_name };
        };

        LET $tag_rec = SELECT id FROM automation_tag WHERE name = $tag_name LIMIT 1;
        IF array::len($tag_rec) = 0 {
            RETURN { success: false, error: 'Tag not found', tag_name: $tag_name };
        };

        LET $node_id = $node_rec[0].id;
        LET $tag_id = $tag_rec[0].id;

        -- Vérifier si la relation existe déjà (RELATION: champs in/out)
        LET $existing = SELECT * FROM automation_node_tag 
            WHERE in = $node_id AND out = $tag_id LIMIT 1;

        IF array::len($existing) > 0 {
            RETURN $existing[0];
        };

        -- Créer la relation avec RELATE
        LET $relation = RELATE $node_id->automation_node_tag->$tag_id SET
            created_at = time::now();

        RETURN $relation[0];
    }
    COMMENT 'Associe un tag à un noeud, en s\'assurant de l\'unicité.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_node_tag_resources_add',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour ajouter un tag à un noeud.'
PERMISSIONS FULL;
