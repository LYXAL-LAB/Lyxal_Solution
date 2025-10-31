-- =================================================================================================
-- |
-- | Fichier : storage_tag_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_tag` qui stocke les tags système.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_tag_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_tag`
    -- ============================================================================================
    
    DEFINE TABLE storage_tag SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Tags des fichiers'
    PERMISSIONS FULL;

    DEFINE FIELD name ON TABLE storage_tag 
    TYPE string
    COMMENT 'Nom du tag';

    DEFINE FIELD is_visible ON TABLE storage_tag 
    TYPE bool
    COMMENT 'Indique si le tag est visible';

    DEFINE FIELD is_editable ON TABLE storage_tag 
    TYPE bool
    COMMENT 'Indique si le tag est editable';

    DEFINE FIELD color ON TABLE storage_tag 
    TYPE option<string>
    COMMENT 'Couleur du tag';

    DEFINE FIELD etag ON TABLE storage_tag 
    TYPE string
    COMMENT 'ETag du tag';

    DEFINE FIELD created_by ON TABLE storage_tag 
    TYPE record<user>
    VALUE type::thing('base_user', $value)
    COMMENT 'Utilisateur qui a créé le tag';

    DEFINE FIELD created_at ON TABLE storage_tag 
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de création du tag';
    
    DEFINE FIELD updated_at ON TABLE storage_tag 
    TYPE datetime
    DEFAULT time::now()
    COMMENT 'Date de mise à jour du tag';
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_tag',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_tag`'
PERMISSIONS FULL;
