-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::resources::user::reenable_notifications`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_user_reenable_notifications_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_resources_user_reenable_notifications_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::resources::user::reenable_notifications`.');

    DEFINE FUNCTION fn::scheduler::resources::user::reenable_notifications() {
        // Réactive les notifications pour l'utilisateur authentifié.
        
        UPDATE $auth.id SET notifications_auto_disabled = false;
        
        RETURN true;
    };
    
    fn::system_log_create_record_system(['scheduler_resources_user_reenable_notifications_initialise', 'success'], 'Fonction `fn::scheduler::resources::user::reenable_notifications` initialisée avec succès.');

    RETURN true;
};
