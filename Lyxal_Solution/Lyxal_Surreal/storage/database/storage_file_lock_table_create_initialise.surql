-- =================================================================================================
-- |
-- | Fichier : storage_file_lock_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_file_lock` pour la gestion des verrous de fichiers.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_file_lock_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_file_lock',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_file_lock`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_file_lock SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Verrous de fichiers'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS file ON TABLE storage_file_lock 
    TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier verrouillé';

    DEFINE FIELD IF NOT EXISTS lock_type ON TABLE storage_file_lock
    -- 0: non verrouillé, >0: partagé, -1: exclusif 
    TYPE number
    COMMENT 'Type de verrouillage';

    DEFINE FIELD IF NOT EXISTS ttl ON TABLE storage_file_lock 
    TYPE datetime
    COMMENT 'Temps de vie du verrou';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_file_lock',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_file_lock`'
PERMISSIONS FULL;
