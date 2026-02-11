-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_usergroupchange`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_usergroupchange_create_table_initialise() {
    -- Création de la table scheduler_usergroupchange
    fn::system_log_create_record_system(['scheduler_usergroupchange_create_table_initialise', 'start'], 'Initialisation de la table `scheduler_usergroupchange`.');

    DEFINE TABLE IF NOT EXISTS scheduler_usergroupchange SCHEMAFULL
        COMMENT 'Journalise les changements de groupe pour les utilisateurs.';

    DEFINE FIELD IF NOT EXISTS usergroupchangeid ON scheduler_usergroupchange TYPE number;
    DEFINE FIELD IF NOT EXISTS userid ON scheduler_usergroupchange TYPE record<scheduler_user>;
    DEFINE FIELD IF NOT EXISTS oldusergroupid ON scheduler_usergroupchange TYPE record<scheduler_usergroup>;
    DEFINE FIELD IF NOT EXISTS newusergroupid ON scheduler_usergroupchange TYPE record<scheduler_usergroup>;
    DEFINE FIELD IF NOT EXISTS created ON scheduler_usergroupchange TYPE datetime;
    DEFINE FIELD IF NOT EXISTS processed ON scheduler_usergroupchange TYPE datetime;

    -- Migration de la clé primaire en tant qu'index unique
    DEFINE INDEX IF NOT EXISTS usergroupchange_id_unique ON scheduler_usergroupchange COLUMNS usergroupchangeid UNIQUE;
    -- Migration de l'index sur processed
    DEFINE INDEX IF NOT EXISTS usergroupchange_processed_idx ON scheduler_usergroupchange COLUMNS processed;
    
    fn::system_log_create_record_system(['scheduler_usergroupchange_create_table_initialise', 'success'], 'Table `scheduler_usergroupchange` initialisée avec succès.');

    RETURN true;
};
