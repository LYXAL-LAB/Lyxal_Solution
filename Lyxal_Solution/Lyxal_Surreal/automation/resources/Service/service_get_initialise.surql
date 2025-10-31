-- =================================================================================================
-- |
-- | Fichier : service_get_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de récupération d'un service.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_service_get_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_service_get',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_service_get(
        $id: string
    ) {
        -- Recherche du service par son ID
        LET $service = SELECT * FROM automation_service 
        WHERE id = type::thing('automation_service', string::lowercase($id));

        -- Vérification si le service existe
        IF array::len($service) = 0 {
            RETURN { success: false, error: "Service non trouvé." };
        };

        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            data: $service[0]
        };
    }
    COMMENT 'Récupère un service par son ID ou son nom.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_service_get',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        message: 'Initialisation de la fonction de récupération de service.',
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de récupération de service.'
PERMISSIONS FULL;
