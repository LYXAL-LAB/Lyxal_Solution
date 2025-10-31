-- =================================================================================================
-- |
-- | Fichier : automation_tag_resources_get_by_id_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction pour récupérer un tag par son ID.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_get_by_id_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_resources_get_by_id',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_get_by_id(
        $id: string
    ) {
        -- Récupérer le tag par son ID
        LET $tag = (SELECT * FROM type::thing('automation_tag', $id) LIMIT 1)[0];
        
        IF $tag == NONE {
            THROW "Aucun tag trouvé avec l'ID fourni.";
        };
        
        RETURN $tag;
    }
    COMMENT 'Récupère un tag par son ID et lève une erreur s\'il n\'est pas trouvé.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_resources_get_by_id',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction pour récupérer un tag par son ID.'
PERMISSIONS FULL;
