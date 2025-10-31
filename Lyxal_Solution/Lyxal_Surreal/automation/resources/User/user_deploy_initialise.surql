-- =================================================================================================
-- DEBUT DU DEPLOIEMENT DES FONCTIONS RESSOURCES USER
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_user_deploy_initialise() {
    -- Log de début d'initialisation
    fn::system_log_create_record_system(['scheduler_resources_user_deploy_initialise', 'start'], 'Déploiement des fonctions ressources pour User.');

    -- Initialisation des fonctions
    fn::scheduler_resources_user_get_group_initialise();
    fn::scheduler_resources_user_reenable_notifications_initialise();

    -- Log de fin d'initialisation
    fn::system_log_create_record_system(['scheduler_resources_user_deploy_initialise', 'success'], 'Déploiement des fonctions ressources pour User terminé avec succès.');

    RETURN true;
};
