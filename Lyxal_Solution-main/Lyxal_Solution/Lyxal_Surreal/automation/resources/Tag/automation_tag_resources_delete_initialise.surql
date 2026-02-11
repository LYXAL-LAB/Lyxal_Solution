-- =================================================================================================
-- |
-- | Fichier : automation_tag_resources_delete_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de suppression de tag.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_delete_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_resources_delete',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_delete(
        $id: string,
        $etag: number
    ) {
        -- 1. Récupérer le tag et vérifier l'ETag
        LET $tag = fn::automation_tag_resources_get_by_id($id);

        IF $tag.etag != $etag {
            THROW "Le tag a été modifié par un autre utilisateur. Veuillez rafraîchir les 
            données et réessayer.";
        };

        -- 2. Supprimer le tag
        DELETE $tag.id;
        
        RETURN {
            success: true,
            message: "Le tag a été supprimé avec succès."
        };
    }
    COMMENT 'Supprime un tag existant après vérification de l\'ETag.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_resources_delete',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de suppression de tag.'
PERMISSIONS FULL;
