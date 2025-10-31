-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA TABLE `scheduler_user_stripe_mapping`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_user_stripe_mapping_create_table_initialise() {
    -- Création de la table scheduler_user_stripe_mapping
    fn::system_log_create_record_system(['scheduler_user_stripe_mapping_create_table_initialise', 'start'], 'Initialisation de la table `scheduler_user_stripe_mapping`.');

    DEFINE TABLE IF NOT EXISTS scheduler_user_stripe_mapping SCHEMAFULL
        COMMENT 'Fait le lien entre un utilisateur du système et un client Stripe.';

    DEFINE FIELD IF NOT EXISTS userid ON scheduler_user_stripe_mapping TYPE record<scheduler_user>;
    DEFINE FIELD IF NOT EXISTS stripe_customer_id ON scheduler_user_stripe_mapping TYPE string DEFAULT '';

    -- Migration des clés en index
    DEFINE INDEX IF NOT EXISTS user_stripe_mapping_userid_unique ON scheduler_user_stripe_mapping COLUMNS userid UNIQUE;
    DEFINE INDEX IF NOT EXISTS user_stripe_mapping_stripeid_unique ON scheduler_user_stripe_mapping COLUMNS stripe_customer_id UNIQUE;
    
    fn::system_log_create_record_system(['scheduler_user_stripe_mapping_create_table_initialise', 'success'], 'Table `scheduler_user_stripe_mapping` initialisée avec succès.');

    RETURN true;
};
