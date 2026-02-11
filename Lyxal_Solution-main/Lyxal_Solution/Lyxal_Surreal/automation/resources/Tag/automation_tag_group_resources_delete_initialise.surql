-- =================================================================================================
-- |
-- | Fichier : automation_tag_group_resources_delete_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour supprimer un tag d'un groupe.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_delete_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_group_resources_delete',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_group_resources_delete(
        $tag_id: string,
        $group_id: string
    ) {
        -- Chercher la relation spécifique
        LET $relation = (
            SELECT * FROM automation_tag_group 
            WHERE tag = type::thing('automation_tag', $tag_id) 
            AND group_user = type::thing('base_user_group', $group_id)
            LIMIT 1
        )[0];

        IF $relation != NONE {
            -- Supprimer la relation si elle existe
            DELETE $relation.id;
            RETURN {
                success: true,
                message: "L'association a été supprimée avec succès."
            };
        };

        RETURN {
            success: true,
            message: "L'association n'existait pas."
        };
    }
    COMMENT 'Supprime l\'association entre un tag et un groupe.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_group_resources_delete',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour supprimer un tag d\'un groupe.'
PERMISSIONS FULL;
