-- =================================================================================================
-- |
-- | Fichier : storage_comment_read_marker_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_comment_read_marker`.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_comment_read_marker_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_comment_read_marker',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_comment_read_marker`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_comment_read_marker SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Marqueurs de lecture des commentaires'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS user ON TABLE storage_comment_read_marker 
    TYPE record<user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur';

    DEFINE FIELD IF NOT EXISTS file ON TABLE storage_comment_read_marker 
    TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier';

    DEFINE FIELD read_up_to ON TABLE storage_comment_read_marker 
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de lecture';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_comment_read_marker',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_comment_read_marker`'
PERMISSIONS FULL;
