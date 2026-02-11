-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::resources::folder::delete`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_resources_folder_delete_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_resources_folder_delete_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::resources::folder::delete`.');

    DEFINE FUNCTION fn::scheduler::resources::folder::delete(
        $id: record<scheduler_folder>
    ) {
        -- Vérifier que le dossier appartient bien à l'utilisateur authentifié avant toute opération
        LET $folder_to_delete = (SELECT * FROM ONLY $id WHERE userid = $auth.id);
        IF count($folder_to_delete) == 0 {
            THROW 'Dossier non trouvé ou permissions insuffisantes.';
        };

        -- Déplacer tous les jobs de ce dossier vers la racine (folderid = NONE)
        -- pour le même utilisateur.
        UPDATE scheduler_job SET folderid = NONE 
            WHERE folderid = $id AND userid = $auth.id;

        -- Supprimer le dossier maintenant qu'il est vide
        DELETE $id;

        RETURN true;
    };
    
    fn::system_log_create_record_system(['scheduler_resources_folder_delete_initialise', 'success'], 'Fonction `fn::scheduler::resources::folder::delete` initialisée avec succès.');

    RETURN true;
};
