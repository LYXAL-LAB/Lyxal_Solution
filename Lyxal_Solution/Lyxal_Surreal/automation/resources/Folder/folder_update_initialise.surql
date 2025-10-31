-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::resources::folder::update`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_folder_update_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_resources_folder_update_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::resources::folder::update`.');

    DEFINE FUNCTION fn::scheduler::resources::folder::update(
        $id: record<scheduler_folder>,
        $title: string
    ) {
        -- L'index unique `folder_user_title_unique` empêchera de renommer un dossier avec un titre déjà existant pour cet utilisateur.
        LET $updated_folder = UPDATE $id SET
            title = $title
        WHERE userid = $auth.id;

        RETURN $updated_folder;
    };
    
    fn::system_log_create_record_system(['scheduler_resources_folder_update_initialise', 'success'], 'Fonction `fn::scheduler::resources::folder::update` initialisée avec succès.');

    RETURN true;
};
