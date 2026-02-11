-- =================================================================================================
-- |
-- | Fichier : system_documentation_create_record_system_initialise.surql
-- | Module : system
-- | Description : Initialise la fonction système pour créer un enregistrement de documentation.
-- |
-- =================================================================================================
DEFINE FUNCTION fn::system_documentation_create_record_system_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_system'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'system_documentation_create_record_system',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION fn::system_documentation_create_record_system(
        $name: string,
        $type: string,
        $format: string,
        $content: object
    ) {
        -- Création de l'enregistrement
        LET $doc = CREATE system_documentation SET
            name = $name,
            type = $type,
            format = $format,
            content = $content;

        RETURN $doc[0];
    }
    COMMENT 'Crée un enregistrement de documentation système sans validation.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'system_documentation_create_record_system',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    RETURN {
        success: true,
        run_id: $run_id
    };
}
COMMENT "Initialise la fonction système de création d'enregistrement de documentation."
PERMISSIONS FULL;
