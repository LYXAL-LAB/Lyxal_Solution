-- =================================================================================================
-- |
-- | Fichier : storage_config_table_create_initialise.surql
-- | Module : storage
-- | Description : Initialise la table `storage_config` pour la configuration des backends de stockage.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_config_table_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'table', 'start', 'storage_config',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- ============================================================================================
    -- == Création de la table `storage_config`
    -- ============================================================================================
    
    DEFINE TABLE IF NOT EXISTS storage_config SCHEMAFULL
    TYPE NORMAL
    COMMENT 'Configuration des backends de stockage'
    PERMISSIONS FULL;

    -- Définition des champs
    DEFINE FIELD IF NOT EXISTS name ON TABLE storage_config 
    TYPE string
    COMMENT 'Nom de la configuration';

    DEFINE FIELD IF NOT EXISTS type ON TABLE storage_config 
    TYPE record<storage_type>
    VALUE type::thing('storage_type', $value)
    COMMENT 'Type de la configuration';

    DEFINE FIELD IF NOT EXISTS config ON TABLE storage_config 
    FLEXIBLE
    TYPE object
    COMMENT 'Configuration';
    
    -- ============================================================================================

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'table', 'done', 'storage_config',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT "Initialise la table `storage_config`."
PERMISSIONS FULL;
