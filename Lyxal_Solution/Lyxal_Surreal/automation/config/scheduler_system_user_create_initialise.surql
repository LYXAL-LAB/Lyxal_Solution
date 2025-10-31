-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE L'UTILISATEUR SYSTEME DU SCHEDULER
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_system_user_create_initialise() {
    -- Log de début
    fn::system_log_create_record_system(['scheduler_system_user_create_initialise', 'start'],
     'Création de l\'utilisateur système du scheduler.');

    -- Création de l'utilisateur système pour le scheduler
    -- Cet utilisateur utilisera les paramètres $scheduler_name et $scheduler_pass
    -- qui doivent être définis au préalable.
    DEFINE USER IF NOT EXISTS $scheduler_name ON ROOT
        PASSWORD $scheduler_pass
        ROLES OWNER
        DURATION FOR SESSION 1h, FOR TOKEN 15m
        COMMENT "Utilisateur système utilisé par le worker pour déclencher le pipeline de jobs.";

    -- Log de fin
    fn::system_log_create_record_system(['scheduler_system_user_create_initialise', 'success'], 
    'Utilisateur système du scheduler créé avec succès.');

    RETURN true;
};
