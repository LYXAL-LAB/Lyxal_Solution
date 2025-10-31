-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_userdeletelog`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_userdeletelog_create_table_initialise() {
    -- Création de la table scheduler_userdeletelog
    fn::system_log_create_record_system(['scheduler_userdeletelog_create_table_initialise', 'start'], 'Initialisation de la table `scheduler_userdeletelog`.');

    DEFINE TABLE IF NOT EXISTS scheduler_userdeletelog SCHEMAFULL
        COMMENT 'Journalise les suppressions d\'utilisateurs.';

    DEFINE FIELD IF NOT EXISTS userid ON scheduler_userdeletelog TYPE record<scheduler_user>;
    DEFINE FIELD IF NOT EXISTS date ON scheduler_userdeletelog TYPE datetime;
    DEFINE FIELD IF NOT EXISTS source ON scheduler_userdeletelog TYPE string DEFAULT 'unknown'
        ASSERT $value IN ['api', 'ops', 'unknown'];
    DEFINE FIELD IF NOT EXISTS date_finished ON scheduler_userdeletelog TYPE datetime;
    DEFINE FIELD IF NOT EXISTS email ON scheduler_userdeletelog TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS email_salt ON scheduler_userdeletelog TYPE string DEFAULT '';

    -- Migration de la clé primaire en tant qu'index unique
    DEFINE INDEX IF NOT EXISTS userdeletelog_userid_unique ON scheduler_userdeletelog COLUMNS userid UNIQUE;
    
    fn::system_log_create_record_system(['scheduler_userdeletelog_create_table_initialise', 'success'], 'Table `scheduler_userdeletelog` initialisée avec succès.');

    RETURN true;
};
