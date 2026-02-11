-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::resources::folder::get_all`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_folder_get_all_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_resources_folder_get_all_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::resources::folder::get_all`.');

    DEFINE FUNCTION fn::scheduler::resources::folder::get_all() {
        RETURN (
            SELECT 
                folderid,
                title 
            FROM scheduler_folder 
            WHERE userid = $auth.id
            ORDER BY title ASC
        );
    };
    
    fn::system_log_create_record_system(['scheduler_resources_folder_get_all_initialise', 'success'], 'Fonction `fn::scheduler::resources::folder::get_all` initialisée avec succès.');

    RETURN true;
};
