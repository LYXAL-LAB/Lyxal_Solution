-- =================================================================================================
-- |
-- | Fichier : storage_file_resources_get_by_name_initialise.surql
-- | Module : storage
-- | Description : Initialise la fonction pour récupérer un fichier par son nom.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::storage_file_resources_get_by_name_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_storage', 'resources'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'storage_file_resources_get_by_name',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION fn::storage_file_resources_get_by_name(
        $name: string
    ) {
        -- Sélectionne le premier fichier correspondant au nom fourni
        LET $file = SELECT * FROM storage_file WHERE name = $name LIMIT 1;
        
        IF count($file) > 0 {
            RETURN $file[0];
        } ELSE {
            RETURN NONE;
        };
    }
    COMMENT 'Récupère un enregistrement de fichier par son nom.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'storage_file_resources_get_by_name',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT 'Initialise la fonction get_by_name pour les ressources de fichiers.'
PERMISSIONS FULL;
