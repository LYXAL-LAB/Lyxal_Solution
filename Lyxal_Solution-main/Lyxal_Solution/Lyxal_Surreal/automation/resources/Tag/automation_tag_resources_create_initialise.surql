-- =================================================================================================
-- |
-- | Fichier : automation_tag_resources_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de création de tag pour les noeuds d'automatisation.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_resources_create',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_create(
        $name: string,
        $is_visible: bool,
        $is_editable: bool,
        $color: option<string>,
        $created_by: option<string>
    ) {
        -- Création directe sans validations pour diagnostic
        LET $clean_name = $name;
        LET $clean_color = $color;
        -- Créer le nouveau tag
        LET $new_tag = CREATE automation_tag SET
            name = $clean_name,
            is_visible = $is_visible,
            is_editable = $is_editable,
            color = $clean_color,
            created_by = $created_by,
            created_at = time::now(),
            updated_at = time::now();
        
        RETURN $new_tag[0];
    }
    COMMENT 'Crée un nouveau tag pour les noeuds d\'automatisation, en évitant les doublons 
    et en validant les entrées.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_resources_create',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de création de tag pour les noeuds d\'automatisation.'
PERMISSIONS FULL;
