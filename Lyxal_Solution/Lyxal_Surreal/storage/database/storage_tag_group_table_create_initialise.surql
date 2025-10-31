-- =================================================================================================
-- |
-- | Fichier : storage_tag_group_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table de liaison `storage_tag_group`.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_tag_group_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_tag_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_tag_group`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_tag_group SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Groupes de tags'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS tag ON TABLE storage_tag_group 
    TYPE record<storage_tag>
    VALUE type::thing('storage_tag', $value)
    COMMENT 'Tag';

    DEFINE FIELD IF NOT EXISTS group ON TABLE storage_tag_group 
    TYPE record<base_user_group>
    VALUE type::thing('user_group', $value)
    COMMENT 'Groupe';
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_tag_group',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table de liaison `storage_tag_group`'
PERMISSIONS FULL;
