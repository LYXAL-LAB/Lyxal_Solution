-- =================================================================================================
-- |
-- | Fichier : system_documentation_delete_record_system_initialise.surql
-- | Module : system
-- | Description : Initialise la fonction système pour supprimer un enregistrement de documentation.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::system_documentation_delete_record_system_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_system'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'system_documentation_delete_record_system',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION fn::system_documentation_delete_record_system(
        $id: record<system_documentation>
    ) {
        -- Suppression de l'enregistrement
        DELETE $id;
        RETURN { success: true, message: "Documentation " + <string>$id + " supprimée." };
    }
    COMMENT 'Supprime un enregistrement de documentation système par son ID.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'system_documentation_delete_record_system',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT "Initialise la fonction système de suppression d'enregistrement de documentation."
PERMISSIONS FULL;
