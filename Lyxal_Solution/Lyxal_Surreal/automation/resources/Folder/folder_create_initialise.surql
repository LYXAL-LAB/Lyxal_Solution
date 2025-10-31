-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::resources::folder::create`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_folder_create_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_resources_folder_create_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::resources::folder::create`.');

    DEFINE FUNCTION fn::scheduler::resources::folder::create(
        $title: string
    ) {
        -- L'index unique `folder_user_title_unique` sur (userid, title) empêchera automatiquement la création de doublons.
        -- SurrealDB lèvera une erreur si la contrainte est violée.
        LET $created_folder = CREATE scheduler_folder SET
            userid = $auth.id,
            title = $title;

        RETURN $created_folder;
    };
    
    fn::system_log_create_record_system(['scheduler_resources_folder_create_initialise', 'success'], 'Fonction `fn::scheduler::resources::folder::create` initialisée avec succès.');

    RETURN true;
};
