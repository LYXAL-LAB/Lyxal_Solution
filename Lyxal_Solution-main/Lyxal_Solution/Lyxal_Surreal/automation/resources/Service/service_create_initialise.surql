-- =================================================================================================
-- |
-- | Fichier : service_create_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de création d'un nouveau service.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_service_create_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_service_create',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_service_create(
        $name: string,
        $organisation_id: string,
        $auth_handler_id: string,
        $documentation_url: option<string>
    ) {
        -- L'ID est basé sur le nom du service pour la lisibilité
        LET $service = 
        CREATE type::thing('automation_service', string::lowercase(string::replace($name, ' ', '-')))
        SET
            name = $name,
            organisation = $organisation_id,
            auth_handler = $auth_handler_id,
            documentation_url = $documentation_url
        ;
     
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            data: $service[0]
        };
    }
    COMMENT 'Crée un nouveau service (ex: Google Sheets) et le lie à une organisation.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_service_create',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        message: 'Initialisation de la fonction de création de service.',
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de création de service.'
PERMISSIONS FULL;
