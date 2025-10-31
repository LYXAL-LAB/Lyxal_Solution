-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_user`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_user_create_table_initialise() {
    -- Création de la table scheduler_user
    fn::system_log_create_record_system(['scheduler_user_create_table_initialise', 'start'], 'Initialisation de la table `scheduler_user`.');

    DEFINE TABLE IF NOT EXISTS scheduler_user SCHEMAFULL
        COMMENT 'Contient les informations sur les utilisateurs.';

    DEFINE FIELD IF NOT EXISTS userid ON scheduler_user TYPE number;
    DEFINE FIELD IF NOT EXISTS usergroupid ON scheduler_user TYPE record<scheduler_usergroup> DEFAULT record<scheduler_usergroup>:1;
    DEFINE FIELD IF NOT EXISTS status ON scheduler_user TYPE number DEFAULT 0;
    DEFINE FIELD IF NOT EXISTS email ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS password ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS password_salt ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS firstname ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS lastname ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS signup_ip ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS signup_date ON scheduler_user TYPE datetime;
    DEFINE FIELD IF NOT EXISTS verification_token ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS verification_date ON scheduler_user TYPE datetime;
    DEFINE FIELD IF NOT EXISTS lastlogin_ip ON scheduler_user TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS lastlogin_date ON scheduler_user TYPE datetime;
    DEFINE FIELD IF NOT EXISTS lastlogin_lang ON scheduler_user TYPE string DEFAULT 'de';
    DEFINE FIELD IF NOT EXISTS timezone ON scheduler_user TYPE string DEFAULT 'Europe/Berlin';
    DEFINE FIELD IF NOT EXISTS newsletter_subscribe ON scheduler_user TYPE string DEFAULT 'undefined'
        ASSERT $value IN ['yes', 'no', 'undefined'];
    DEFINE FIELD IF NOT EXISTS notifications_auto_disabled ON scheduler_user TYPE bool DEFAULT false;
    DEFINE FIELD IF NOT EXISTS last_password_change ON scheduler_user TYPE datetime;

    -- Migration de la clé primaire en tant qu'index unique pour conserver l'intégrité
    DEFINE INDEX IF NOT EXISTS user_userid_unique ON scheduler_user COLUMNS userid UNIQUE;
    -- Migration de l'index sur l'email
    DEFINE INDEX IF NOT EXISTS user_email_idx ON scheduler_user COLUMNS email;
    
    fn::system_log_create_record_system(['scheduler_user_create_table_initialise', 'success'], 'Table `scheduler_user` initialisée avec succès.');

    RETURN true;
};
