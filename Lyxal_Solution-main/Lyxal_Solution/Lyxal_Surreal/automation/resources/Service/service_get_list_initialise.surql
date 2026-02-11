-- =================================================================================================
-- |
-- | Fichier : service_get_list_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de récupération de la liste des services.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_service_get_list_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_service_get_list',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_service_get_list() {
        -- Recherche des services
        LET $services = SELECT * FROM automation_service ORDER BY name ASC;

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            data: $services
        };
    }
    COMMENT 'Récupère la liste de tous les services.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_service_get_list',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        message: 'Initialisation de la fonction de récupération de la liste des services.',
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de récupération de la liste des services.'
PERMISSIONS FULL;
