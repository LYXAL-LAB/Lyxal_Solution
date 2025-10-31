-- =================================================================================================
-- |
-- | Fichier : storage_file_version_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_file_version` qui stocke les versions des fichiers.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_file_version_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_file_version',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_file_version`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_file_version SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Versions des fichiers'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS file ON TABLE storage_file_version 
    TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier';

    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE storage_file_version 
    TYPE datetime
    COMMENT 'Date de la version';

    DEFINE FIELD IF NOT EXISTS size ON TABLE storage_file_version 
    TYPE number
    COMMENT 'Taille du fichier';

    DEFINE FIELD IF NOT EXISTS mime_type ON TABLE storage_file_version 
    TYPE string
    COMMENT 'Type MIME du fichier';

    DEFINE FIELD IF NOT EXISTS metadata ON TABLE storage_file_version
    FLEXIBLE
    TYPE object
    COMMENT 'Métadonnées du fichier';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_file_version',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_file_version`'
PERMISSIONS FULL;
