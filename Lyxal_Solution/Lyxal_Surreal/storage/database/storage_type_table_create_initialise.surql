-- =================================================================================================
-- |
-- | Fichier : storage_type_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_type` pour les types de backends de stockage.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_type_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_type',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_type`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_type SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Types de backends de stockage'
    PERMISSIONS FULL;

    -- Définition des champs
    DEFINE FIELD IF NOT EXISTS name ON TABLE storage_type 
    TYPE string
    COMMENT 'Nom du type de stockage (ex: LOCAL, S3)';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_type',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la table `storage_type`'
PERMISSIONS FULL;
