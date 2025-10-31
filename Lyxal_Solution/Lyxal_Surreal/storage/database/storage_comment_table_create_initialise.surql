-- =================================================================================================
-- |
-- | Fichier : storage_comment_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_comment` qui stocke les commentaires.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_comment_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_comment',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_comment`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_comment SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Commentaires'
    PERMISSIONS FULL;

    -- Définition des champs
    DEFINE FIELD IF NOT EXISTS parent ON TABLE storage_comment 
    TYPE option<record<storage_comment>>
    VALUE type::thing('storage_comment', $value)
    COMMENT 'Commentaire parent';

    DEFINE FIELD IF NOT EXISTS topmost_parent ON TABLE storage_comment 
    TYPE option<record<storage_comment>>
    VALUE type::thing('storage_comment', $value)
    COMMENT 'Commentaire parent le plus haut';

    DEFINE FIELD IF NOT EXISTS author ON TABLE storage_comment 
    TYPE record<base_user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Auteur du commentaire';

    DEFINE FIELD IF NOT EXISTS message ON TABLE storage_comment 
    TYPE string
    COMMENT 'Message du commentaire';

    DEFINE FIELD IF NOT EXISTS verb ON TABLE storage_comment 
    TYPE string
    COMMENT 'Verbe du commentaire';

    DEFINE FIELD created_at ON TABLE storage_comment 
    TYPE datetime
    COMMENT 'Date de création du commentaire';

    DEFINE FIELD IF NOT EXISTS last_reply_at ON TABLE storage_comment 
    TYPE option<datetime>
    COMMENT 'Date de la dernière réponse';

    DEFINE FIELD IF NOT EXISTS file ON TABLE storage_comment 
    TYPE record<storage_file>
    VALUE type::thing('storage_file', $value)
    COMMENT 'Fichier du commentaire';

    DEFINE FIELD IF NOT EXISTS expires_at ON TABLE storage_comment 
    TYPE option<datetime>
    COMMENT 'Date d\'expiration du commentaire';

    DEFINE FIELD IF NOT EXISTS reference_id ON TABLE storage_comment 
    TYPE option<string>
    COMMENT 'ID de référence du commentaire';

    DEFINE FIELD IF NOT EXISTS metadata ON TABLE storage_comment 
    FLEXIBLE
    TYPE object
    COMMENT 'Métadonnées du commentaire';

    DEFINE FIELD IF NOT EXISTS reactions ON TABLE storage_comment 
    FLEXIBLE
    TYPE object
    COMMENT 'Réactions au commentaire';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_comment',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_comment`'
PERMISSIONS FULL;
