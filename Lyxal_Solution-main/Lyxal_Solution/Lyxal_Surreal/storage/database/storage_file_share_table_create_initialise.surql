-- =================================================================================================
-- |
-- | Fichier : storage_file_share_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_file_share` qui stocke les partages de fichiers.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_file_share_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_file_share',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_file_share`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_file_share SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Partages de fichiers'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS file ON TABLE storage_file_share 
    TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier partagé';

    DEFINE FIELD IF NOT EXISTS share_type ON TABLE storage_file_share 
    TYPE string
    COMMENT 'Type de partage';

    DEFINE FIELD IF NOT EXISTS share_with ON TABLE storage_file_share 
    TYPE array<record<base_user>>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur avec qui le fichier est partagé';

    DEFINE FIELD IF NOT EXISTS shared_by ON TABLE storage_file_share 
    TYPE record<base_user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur qui a partagé le fichier';

    DEFINE FIELD IF NOT EXISTS share_owner ON TABLE storage_file_share 
    TYPE record<base_user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur qui est propriétaire du partage';

    DEFINE FIELD IF NOT EXISTS permissions ON TABLE storage_file_share 
    TYPE string
    COMMENT 'Permissions du partage';

    DEFINE FIELD IF NOT EXISTS status ON TABLE storage_file_share 
    TYPE string
    COMMENT 'Statut du partage';

    DEFINE FIELD IF NOT EXISTS note ON TABLE storage_file_share 
    TYPE string
    COMMENT 'Note du partage';

    DEFINE FIELD IF NOT EXISTS label ON TABLE storage_file_share 
    TYPE string
    COMMENT 'Label du partage';

    DEFINE FIELD IF NOT EXISTS expire_date ON TABLE storage_file_share 
    TYPE option<datetime>
    COMMENT 'Date d\'expiration du partage';

    DEFINE FIELD IF NOT EXISTS password ON TABLE storage_file_share 
    TYPE option<string>
    COMMENT 'Mot de passe du partage';

    DEFINE FIELD IF NOT EXISTS token ON TABLE storage_file_share 
    TYPE string
    COMMENT 'Token du partage';

    DEFINE FIELD IF NOT EXISTS parent_share ON TABLE storage_file_share 
    TYPE option<record<storage_file_share>>
    COMMENT 'Partage parent';

    DEFINE FIELD IF NOT EXISTS created_at ON TABLE storage_file_share 
    TYPE datetime
    COMMENT 'Date de création du partage';

    DEFINE FIELD IF NOT EXISTS hide_download ON TABLE storage_file_share 
    TYPE bool
    COMMENT 'Masquer le téléchargement du partage';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_file_share',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_file_share`'
PERMISSIONS FULL;
