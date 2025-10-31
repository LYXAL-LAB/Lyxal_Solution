-- =================================================================================================
-- |
-- | Fichier : storage_comment_reaction_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_comment_reaction`.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_comment_reaction_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_comment_reaction',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_comment_reaction`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_comment_reaction SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Réactions aux commentaires'
    PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS comment ON TABLE storage_comment_reaction 
    TYPE record<storage_comment>
    VALUE type::thing('storage_comment', $value)
    COMMENT 'Commentaire réagi';

    DEFINE FIELD IF NOT EXISTS author ON TABLE storage_comment_reaction 
    TYPE record<base_user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Auteur de la réaction';

    DEFINE FIELD IF NOT EXISTS reaction ON TABLE storage_comment_reaction 
    TYPE string
    COMMENT 'Réaction';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_comment_reaction',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_comment_reaction`'
PERMISSIONS FULL;
