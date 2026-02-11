-- =================================================================================================
-- |
-- | Fichier : storage_mount_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_mount`.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_mount_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_mount',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_mount`
    -- ============================================================================================
    
    DEFINE TABLE storage_mount SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Montages des backends de stockage'
    PERMISSIONS FULL;

    DEFINE FIELD config ON TABLE storage_mount 
    TYPE record<storage_config>
    VALUE type::thing('storage_config', $value)
    COMMENT 'Configuration';

    DEFINE FIELD root_file ON TABLE storage_mount 
    TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier racine';

    DEFINE FIELD user ON TABLE storage_mount 
    TYPE record<user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur';

    DEFINE FIELD mount_point ON TABLE storage_mount 
    TYPE string
    COMMENT 'Point de montage';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_mount',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_mount`'
PERMISSIONS FULL;
