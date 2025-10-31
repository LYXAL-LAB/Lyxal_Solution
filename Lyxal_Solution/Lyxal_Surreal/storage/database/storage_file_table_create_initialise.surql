-- =================================================================================================
-- |
-- | Fichier : storage_file_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_file` qui stocke les informations sur les fichiers.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_file_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_file',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_file`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_file SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Fichiers stockés'
    PERMISSIONS FULL;

    -- Définition des champs
    DEFINE FIELD IF NOT EXISTS name ON TABLE storage_file 
    TYPE string
    COMMENT 'Nom du fichier';

    DEFINE FIELD IF NOT EXISTS size ON TABLE storage_file 
    TYPE number
    COMMENT 'Taille du fichier';
    
    DEFINE FIELD mime_type ON TABLE storage_file 
    TYPE string
    COMMENT 'Type MIME du fichier';

    DEFINE FIELD storage_path ON TABLE storage_file 
    TYPE string
    COMMENT 'Chemin de stockage du fichier';

    DEFINE FIELD user ON TABLE storage_file 
    TYPE record<user>
    COMMENT 'Utilisateur propriétaire du fichier';

    DEFINE FIELD mtime ON TABLE storage_file 
    TYPE datetime
    COMMENT 'Date de modification du fichier';

    DEFINE FIELD ctime ON TABLE storage_file 
    TYPE datetime
    COMMENT 'Date de création du fichier';

    DEFINE FIELD upload_time ON TABLE storage_file 
    TYPE datetime
    COMMENT 'Date de téléchargement du fichier';

    DEFINE FIELD etag ON TABLE storage_file 
    TYPE string
    COMMENT 'Etag du fichier';

    DEFINE FIELD checksum ON TABLE storage_file 
    TYPE string
    COMMENT 'Checksum du fichier';

    DEFINE FIELD parent ON TABLE storage_file 
    TYPE option<record<storage_file>>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier parent';

    DEFINE FIELD is_encrypted ON TABLE storage_file 
    TYPE bool
    COMMENT 'Indique si le fichier est encrypté';

    DEFINE FIELD permissions ON TABLE storage_file 
    TYPE string
    COMMENT 'Permissions du fichier';

    DEFINE FIELD metadata ON TABLE storage_file 
    TYPE object
    COMMENT 'Métadonnées du fichier';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_file',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_file`'
PERMISSIONS FULL;
