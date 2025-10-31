-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_usergroup`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_usergroup_create_table_initialise() {
    -- Création de la table scheduler_usergroup
    fn::system_log_create_record_system(['scheduler_usergroup_create_table_initialise', 'start'], 'Initialisation de la table `scheduler_usergroup`.');

    DEFINE TABLE IF NOT EXISTS scheduler_usergroup SCHEMAFULL
        COMMENT 'Définit les groupes d\'utilisateurs et leurs permissions/limites.';

    DEFINE FIELD IF NOT EXISTS usergroupid ON scheduler_usergroup TYPE number;
    DEFINE FIELD IF NOT EXISTS title ON scheduler_usergroup TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS max_status_pages ON scheduler_usergroup TYPE number DEFAULT 5;
    DEFINE FIELD IF NOT EXISTS max_status_page_monitors ON scheduler_usergroup TYPE number DEFAULT 10;
    DEFINE FIELD IF NOT EXISTS max_status_page_domains ON scheduler_usergroup TYPE number DEFAULT 2;
    DEFINE FIELD IF NOT EXISTS request_timeout ON scheduler_usergroup TYPE number DEFAULT 30;
    DEFINE FIELD IF NOT EXISTS request_max_size ON scheduler_usergroup TYPE number DEFAULT 8192;
    DEFINE FIELD IF NOT EXISTS max_failures ON scheduler_usergroup TYPE number DEFAULT 15;
    DEFINE FIELD IF NOT EXISTS execution_priority ON scheduler_usergroup TYPE number DEFAULT 0;
    DEFINE FIELD IF NOT EXISTS api_requests_per_day ON scheduler_usergroup TYPE number DEFAULT 100;
    DEFINE FIELD IF NOT EXISTS max_api_keys ON scheduler_usergroup TYPE number DEFAULT 1;
    DEFINE FIELD IF NOT EXISTS enable_waf_validator ON scheduler_usergroup TYPE bool DEFAULT true;

    -- Migration de la clé primaire en tant qu'index unique pour conserver l'intégrité
    DEFINE INDEX IF NOT EXISTS usergroup_usergroupid_unique ON scheduler_usergroup COLUMNS usergroupid UNIQUE;
    
    fn::system_log_create_record_system(['scheduler_usergroup_create_table_initialise', 'success'], 'Table `scheduler_usergroup` initialisée avec succès.');

    RETURN true;
};
