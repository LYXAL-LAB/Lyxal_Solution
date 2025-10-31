-- =================================================================================================
-- |
-- | Fichier : storage_file_trash_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_file_trash` qui stocke les informations sur les fichiers supprimés.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_file_trash_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_file_trash',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_file_trash`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_file_trash SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Corbeille des fichiers'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS file ON TABLE storage_file_trash 
    TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier supprimé';

    DEFINE FIELD IF NOT EXISTS user ON TABLE storage_file_trash 
    TYPE record<user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur qui a supprimé le fichier';

    DEFINE FIELD IF NOT EXISTS deleted_by ON TABLE storage_file_trash 
    TYPE record<user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur qui a supprimé le fichier';

    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE storage_file_trash 
    TYPE datetime
    COMMENT 'Date de suppression du fichier';

    DEFINE FIELD IF NOT EXISTS original_location ON TABLE storage_file_trash 
    TYPE string
    COMMENT 'Emplacement original du fichier';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_file_trash',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_file_trash`'
PERMISSIONS FULL;
