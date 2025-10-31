-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_refreshtoken`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_refreshtoken_create_table_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_scheduler'];
    LET $run_id = rand::uuid();

    -- Création de la table scheduler_refreshtoken
    fn::system_log_create_record_system(['scheduler_refreshtoken_create_table_initialise', 'start'],
     'Initialisation de la table `scheduler_refreshtoken`.',
     { log_extra_tags: ['module_scheduler'], run_id: $run_id, parent_run_id: $parent_run_id });

    DEFINE TABLE IF NOT EXISTS scheduler_refreshtoken TYPE SCHEMAFULL
        COMMENT 'Stocke les jetons de rafraîchissement (refresh tokens) pour l\'authentification.'
        PERMISSIONS FULL;

    DEFINE FIELD IF NOT EXISTS token ON scheduler_refreshtoken TYPE string DEFAULT ''
        COMMENT 'Jeton de rafraîchissement.';

    DEFINE FIELD IF NOT EXISTS environmentid ON scheduler_refreshtoken TYPE record<system_environment>
        COMMENT 'Lien vers l\'environment.';

    DEFINE FIELD IF NOT EXISTS device ON scheduler_refreshtoken TYPE string DEFAULT ''
        COMMENT 'Dispositif.';

    DEFINE FIELD IF NOT EXISTS expires ON scheduler_refreshtoken TYPE datetime
        COMMENT 'Date d\'expiration.';

    -- Migration de la clé primaire en tant qu'index unique
    DEFINE INDEX IF NOT EXISTS refreshtoken_token_unique ON scheduler_refreshtoken 
    FIELDS token UNIQUE
    COMMENT 'Index sur le jeton de rafraîchissement.';
    
    fn::system_log_create_record_system(['scheduler_refreshtoken_create_table_initialise', 'success'],
     'Table `scheduler_refreshtoken` initialisée avec succès.',
     { log_extra_tags: ['module_scheduler'], run_id: $run_id, parent_run_id: $parent_run_id });

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
};
