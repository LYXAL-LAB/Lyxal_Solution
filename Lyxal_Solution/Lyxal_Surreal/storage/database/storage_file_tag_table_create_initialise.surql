-- =================================================================================================
-- |
-- | Fichier : storage_file_tag_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table de liaison `storage_file_tag`.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_file_tag_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_file_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_file_tag`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_file_tag SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Relation entre un fichier et un tag'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS file ON TABLE storage_file_tag TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier';

    DEFINE FIELD IF NOT EXISTS tag ON TABLE storage_file_tag TYPE record<storage_tag>
    VALUE type::thing('storage_tag', $value)
    COMMENT 'Tag';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_file_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table de liaison `storage_file_tag`'
PERMISSIONS FULL;
