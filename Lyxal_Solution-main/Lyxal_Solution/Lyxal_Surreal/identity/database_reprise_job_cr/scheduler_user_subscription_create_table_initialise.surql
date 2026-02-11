-- ="================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_user_subscription`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_user_subscription_create_table_initialise() {
    -- Création de la table scheduler_user_subscription
    fn::system_log_create_record_system(['scheduler_user_subscription_create_table_initialise', 'start'], 'Initialisation de la table `scheduler_user_subscription`.');

    DEFINE TABLE IF NOT EXISTS scheduler_user_subscription SCHEMAFULL
        COMMENT 'Stocke les informations sur les abonnements (Stripe) des utilisateurs.';

    DEFINE FIELD IF NOT EXISTS userid ON scheduler_user_subscription TYPE record<scheduler_user>;
    DEFINE FIELD IF NOT EXISTS product_id ON scheduler_user_subscription TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS subscription_id ON scheduler_user_subscription TYPE string DEFAULT '';
    DEFINE FIELD IF NOT EXISTS current_period_start ON scheduler_user_subscription TYPE datetime;
    DEFINE FIELD IF NOT EXISTS current_period_end ON scheduler_user_subscription TYPE datetime;
    DEFINE FIELD IF NOT EXISTS cancel_at ON scheduler_user_subscription TYPE datetime;
    DEFINE FIELD IF NOT EXISTS status ON scheduler_user_subscription TYPE number DEFAULT 0;

    -- Migration de la clé primaire en tant qu'index unique
    DEFINE INDEX IF NOT EXISTS user_subscription_userid_unique ON scheduler_user_subscription COLUMNS userid UNIQUE;
    
    fn::system_log_create_record_system(['scheduler_user_subscription_create_table_initialise', 'success'], 'Table `scheduler_user_subscription` initialisée avec succès.');

    RETURN true;
};
