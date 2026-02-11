-- =================================================================================================
-- DEBUT DU DEPLOIEMENT DES FONCTIONS RESSOURCES FOLDER
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_folder_deploy_initialise() {
    -- Log de début d'initialisation
    fn::system_log_create_record_system(['scheduler_resources_folder_deploy_initialise', 'start'], 'Déploiement des fonctions ressources pour Folder.');

    -- Initialisation des fonctions
    fn::scheduler_resources_folder_get_all_initialise();
    fn::scheduler_resources_folder_create_initialise();
    fn::scheduler_resources_folder_update_initialise();
    fn::scheduler_resources_folder_delete_initialise();

    -- Log de fin d'initialisation
    fn::system_log_create_record_system(['scheduler_resources_folder_deploy_initialise', 'success'], 'Déploiement des fonctions ressources pour Folder terminé avec succès.');

    RETURN true;
};
