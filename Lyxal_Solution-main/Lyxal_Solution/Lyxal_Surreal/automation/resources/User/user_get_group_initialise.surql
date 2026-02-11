-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::resources::user::get_group`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_user_get_group_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_resources_user_get_group_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::resources::user::get_group`.');

    DEFINE FUNCTION fn::scheduler::resources::user::get_group() {
        // Récupère le groupe de l'utilisateur authentifié et les quotas associés.
        // L'information est directement disponible via le scope d'authentification.
        
        RETURN (
            SELECT *
            FROM ONLY $auth.usergroupid
        );
    };
    
    fn::system_log_create_record_system(['scheduler_resources_user_get_group_initialise', 'success'], 'Fonction `fn::scheduler::resources::user::get_group` initialisée avec succès.');

    RETURN true;
};
