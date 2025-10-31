-- =================================================================================================
-- |
-- | Fichier : automation_tag_group_resources_add_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour ajouter un tag à un groupe.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_add_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_group_resources_add',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_add(
        $tag_id: string,
        $group_id: string
    ) {
        -- Vérifier si la relation existe déjà
        LET $existing = SELECT * FROM automation_tag_group 
            WHERE tag = $tag_id AND group_user = $group_id;

        IF array::len($existing) > 0 {
            -- La relation existe déjà, on la retourne simplement
            RETURN $existing[0];
        };

        -- Créer la nouvelle relation
        LET $relation = CREATE automation_tag_group SET
            tag = $tag_id,
            group_user = $group_id;
        
        RETURN $relation[0];
    }
    COMMENT 'Associe un tag à un groupe, en s\'assurant de l\'unicité.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_group_resources_add',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour ajouter un tag à un groupe.'
PERMISSIONS FULL;
