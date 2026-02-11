-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_user_pwreset`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_user_pwreset_create_table_initialise() {
    -- Création de la table scheduler_user_pwreset
    fn::system_log_create_record_system(['scheduler_user_pwreset_create_table_initialise', 'start'], 'Initialisation de la table `scheduler_user_pwreset`.');

    DEFINE TABLE IF NOT EXISTS scheduler_user_pwreset SCHEMAFULL
        COMMENT 'Stocke les informations pour la réinitialisation des mots de passe utilisateur.';

    DEFINE FIELD IF NOT EXISTS userid ON scheduler_user_pwreset TYPE record<scheduler_user>;
    DEFINE FIELD IF NOT EXISTS expires ON scheduler_user_pwreset TYPE datetime;
    DEFINE FIELD IF NOT EXISTS token ON scheduler_user_pwreset TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS password ON scheduler_user_pwreset TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS password_salt ON scheduler_user_pwreset TYPE string DEFAULT '';

    -- Migration de la clé primaire en tant qu'index unique pour conserver l'intégrité
    DEFINE INDEX IF NOT EXISTS user_pwreset_userid_unique ON scheduler_user_pwreset COLUMNS userid UNIQUE;
    -- Migration de l'index sur expires
    DEFINE INDEX IF NOT EXISTS user_pwreset_expires_idx ON scheduler_user_pwreset COLUMNS expires;
    
    fn::system_log_create_record_system(['scheduler_user_pwreset_create_table_initialise', 'success'], 'Table `scheduler_user_pwreset` initialisée avec succès.');

    RETURN true;
};
